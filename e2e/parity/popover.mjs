// Popover: the Demo, opened by click and by keyboard; focus into the
// content and back to the trigger; Tab looping within it; Escape, an
// outside click and the trigger close it, with the exit animation; its
// place under the trigger, also after the page scrolls.
import { both, each, inRoot, shot, wait } from "./lib.mjs";
import { closing, near, outside, press, state } from "./overlay.mjs";

const sel = { trigger: "[data-slot=popover-trigger]", content: "[data-slot=popover-content]" };
const b = await both();
await b.open("popover", "Demo", "popover-demo");
const trigger = (p) => inRoot(p, sel.trigger);
await state(b, "closed", sel);
await each(b, (p) => trigger(p).click());
await wait(b, 300);
const opened = await state(b, "click opens", sel);
console.log(`position within 3px: ${near(opened)}`);
await shot(b, "popover-open");
for (let i = 1; i <= 4; i++) {
  await press(b, "Tab");
  await state(b, `Tab ${i}`, sel);
}
await press(b, "Shift+Tab");
await state(b, "Shift+Tab", sel);
await closing(b, "Escape: removed after", sel.content, (p) => p.keyboard.press("Escape"));
await state(b, "after Escape", sel);
await press(b, "Enter");
await wait(b, 300);
await state(b, "Enter opens", sel);
await press(b, "Escape");
await wait(b, 400);
await press(b, "Space");
await wait(b, 300);
await state(b, "Space opens", sel);
await closing(b, "outside click: removed after", sel.content, async (p) => {
  await p.locator("[data-parity-root]").click({ position: { x: 6, y: 6 }, force: true });
});
await state(b, "after outside click", sel);
await each(b, (p) => trigger(p).click());
await wait(b, 300);
await closing(b, "trigger click: removed after", sel.content, (p) => trigger(p).click());
await state(b, "after trigger click", sel);
// Scrolling the page with it open: it follows the trigger.
await each(b, (p) => trigger(p).click());
await wait(b, 300);
await each(b, async (p) => { await p.mouse.move(20, 450); await p.mouse.wheel(0, 120); });
await wait(b, 300);
const scrolled = await state(b, "page scrolled while open", sel);
console.log(`position within 3px after scrolling: ${near(scrolled)}`);
await b.close();
