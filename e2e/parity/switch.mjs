// Switch: the demo: click, the label, Space and Enter, the thumb's position
// and transition, attributes, focus ring, look (light and dark).
import { both, compare, each, focused, inRoot, shotRoot as shot, slots, wait } from "./lib.mjs";

const SEL = "[data-slot=switch], [data-slot=switch-thumb]";
const b = await both();
await b.open("switch", "Demo", "switch-demo");
await compare(b, "initial", slots, SEL);
await shot(b, "switch-off");
const sw = (p) => inRoot(p, "[data-slot=switch]");
await each(b, (p) => sw(p).click());
await wait(b, 20);
await compare(b, "click (20ms): thumb transition", () => { const t = document.querySelector("[data-parity-root] [data-slot=switch-thumb]"); return [getComputedStyle(t).transitionProperty, getComputedStyle(t).transitionDuration]; });
await wait(b, 300);
await compare(b, "click: on", slots, SEL);
await compare(b, "focus", focused);
await shot(b, "switch-on");
await each(b, (p) => p.keyboard.press("Space"));
await wait(b, 300);
await compare(b, "Space: off", slots, SEL);
await each(b, (p) => p.keyboard.press("Enter"));
await wait(b, 300);
await compare(b, "Enter", slots, SEL);
await each(b, (p) => inRoot(p, "label").click());
await wait(b, 300);
await compare(b, "click the label", slots, SEL);
await each(b, (p) => p.keyboard.press("Shift+Tab"));
await each(b, (p) => p.keyboard.press("Tab"));
await compare(b, "Tab in: focus", focused);
await compare(b, "focus ring", () => getComputedStyle(document.activeElement).boxShadow);
await shot(b, "switch-focus");
await each(b, (p) => p.evaluate(() => document.documentElement.classList.add("dark")));
await wait(b, 300);
await shot(b, "switch-dark");
await compare(b, "dark colours", () => { const s = document.querySelector("[data-parity-root] [data-slot=switch]"); const t = s.firstElementChild; return [getComputedStyle(s).backgroundColor, getComputedStyle(t).backgroundColor]; });
await b.close();
