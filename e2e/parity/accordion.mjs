// Accordion: the demo (single, collapsible, item 1 open): clicking,
// keyboard (Tab, arrows, Home/End, Enter/Space), the open/close animation
// and the content's height after it.
import { both, compare, each, focused, inRoot, matchPreview, shotRoot as shot, slots, wait } from "./lib.mjs";

const b = await both();
await b.open("accordion", "Demo", "accordion-demo");
await matchPreview(b);
const SEL = "[data-slot=accordion-item], [data-slot=accordion-trigger], [data-slot=accordion-content], [data-slot=accordion-trigger] svg";
await compare(b, "initial", slots, SEL);
await shot(b, "accordion-initial");
const trig = (p, i) => inRoot(p, `[data-slot=accordion-item]:nth-child(${i}) [data-slot=accordion-trigger]`);
await each(b, (p) => trig(p, 2).click());
// mid-animation
await wait(b, 80);
await compare(b, "click item 2, 80ms in", () =>
  [...document.querySelectorAll("[data-parity-root] [data-slot=accordion-content]")].map((c) => [c.dataset.state, Math.round(c.getBoundingClientRect().height), getComputedStyle(c).animationName]));
await wait(b, 400);
await compare(b, "click item 2, settled", slots, SEL);
await compare(b, "focus", focused);
await shot(b, "accordion-item2");
await each(b, (p) => p.keyboard.press("ArrowDown"));
await compare(b, "ArrowDown", focused);
await each(b, (p) => p.keyboard.press("ArrowDown"));
await compare(b, "ArrowDown (loop)", focused);
await each(b, (p) => p.keyboard.press("ArrowUp"));
await compare(b, "ArrowUp (loop back)", focused);
await each(b, (p) => p.keyboard.press("End"));
await compare(b, "End", focused);
await each(b, (p) => p.keyboard.press("Home"));
await compare(b, "Home", focused);
await each(b, (p) => p.keyboard.press("Space"));
await wait(b, 400);
await compare(b, "Space on item 1", slots, SEL);
await each(b, (p) => p.keyboard.press("Enter"));
await wait(b, 400);
await compare(b, "Enter on item 1", slots, SEL);
await each(b, (p) => p.keyboard.press("Tab"));
await compare(b, "Tab", focused);
await shot(b, "accordion-keys");
// Collapsible: clicking the open item closes it.
await each(b, (p) => trig(p, 1).click());
await wait(b, 400);
await compare(b, "click open item 1 (collapse)", slots, SEL);
await b.close();
