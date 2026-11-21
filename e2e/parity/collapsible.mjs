// Collapsible: the demo: the trigger by click and keyboard, the content's
// state, attributes and layout.
// (loon's Collapsible.trigger_attrs leave the button's data-slot, so the
// trigger is found as button[aria-expanded].)
import { both, compare, each, focused, inRoot, shotRoot as shot, slots, wait } from "./lib.mjs";

const b = await both();
await b.open("collapsible", "Demo", "collapsible-demo");
const SEL = "[data-slot=collapsible], button[aria-expanded], [data-slot=collapsible-content], [data-slot=collapsible-content] > div";
await compare(b, "initial", slots, SEL);
await shot(b, "collapsible-closed");
await each(b, (p) => inRoot(p, "button[aria-expanded]").click());
await wait(b, 50);
await compare(b, "click (50ms)", () => [...document.querySelectorAll("[data-parity-root] [data-slot=collapsible-content]")].map((c) => [c.dataset.state, getComputedStyle(c).animationName, Math.round(c.getBoundingClientRect().height)]));
await wait(b, 400);
await compare(b, "click: open", slots, SEL);
await compare(b, "focus", focused);
await shot(b, "collapsible-open");
await each(b, (p) => p.keyboard.press("Enter"));
await wait(b, 400);
await compare(b, "Enter: closed", slots, SEL);
await each(b, (p) => p.keyboard.press("Space"));
await wait(b, 400);
await compare(b, "Space: open", slots, SEL);
await b.close();
