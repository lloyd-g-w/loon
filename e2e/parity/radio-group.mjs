// Radio group: the demo: clicking items and labels, roving focus (arrows
// check as they move, loop), Space, Tab in and out, attributes and look.
import { both, compare, each, focused, inRoot, shotRoot as shot, slots, wait } from "./lib.mjs";

const SEL = "[data-slot=radio-group], [data-slot=radio-group-item], [data-slot=radio-group-indicator], input[type=radio]";
const b = await both();
await b.open("radio_group", "Demo", "radio-group-demo");
await compare(b, "initial", slots, SEL);
await shot(b, "radio-initial");
await each(b, (p) => inRoot(p, "[data-slot=radio-group-item]").click());
await wait(b, 50);
await compare(b, "click 1st", slots, SEL);
await compare(b, "focus", focused);
await each(b, (p) => inRoot(p, "label[for=r3]").click());
await wait(b, 50);
await compare(b, "click label 3", slots, SEL);
await compare(b, "focus after label", focused);
await each(b, (p) => inRoot(p, "[data-slot=radio-group-item]").focus());
for (const key of ["ArrowDown", "ArrowDown", "ArrowDown", "ArrowUp", "ArrowRight", "ArrowLeft", "Home", "End", "Space"]) {
  await each(b, (p) => p.keyboard.press(key));
  await wait(b, 50);
  await compare(b, key, () => [...document.querySelectorAll("[data-parity-root] [data-slot=radio-group-item]")].map((r) => `${r.dataset.state}${r === document.activeElement ? "*" : ""}${r.tabIndex}`).join(" "));
}
await shot(b, "radio-keys");
await each(b, (p) => p.keyboard.press("Shift+Tab"));
await each(b, (p) => p.keyboard.press("Tab"));
await compare(b, "Tab back in: focus", focused);
await b.close();
