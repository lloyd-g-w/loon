// Tabs: the demo: clicking, roving focus (arrows, loop, Home/End, Tab into
// the panel), attributes and layout.
import { both, compare, each, focused, inRoot, matchPreview, shotRoot as shot, slots, wait } from "./lib.mjs";

const b = await both();
await b.open("tabs", "Demo", "tabs-demo");
await matchPreview(b);
const SEL = "[data-slot=tabs], [data-slot=tabs-list], [data-slot=tabs-trigger], [data-slot=tabs-content]";
await compare(b, "initial", slots, SEL);
await shot(b, "tabs-initial");
await each(b, (p) => inRoot(p, "[data-slot=tabs-trigger]:nth-child(2)").click());
await wait(b, 100);
await compare(b, "click Password", slots, SEL);
await compare(b, "focus", focused);
await shot(b, "tabs-password");
for (const key of ["ArrowRight", "ArrowRight", "ArrowLeft", "End", "Home", "ArrowDown"]) {
  await each(b, (p) => p.keyboard.press(key));
  await wait(b, 50);
  await compare(b, `${key}`, focused);
  await compare(b, `${key}: active`, () => [...document.querySelectorAll("[data-parity-root] [data-slot=tabs-trigger]")].map((t) => t.dataset.state));
}
await each(b, (p) => p.keyboard.press("Tab"));
await compare(b, "Tab (into the panel)", focused);
await each(b, (p) => p.keyboard.press("Shift+Tab"));
await compare(b, "Shift+Tab (back to the active tab)", focused);
await shot(b, "tabs-keys");
await b.close();
