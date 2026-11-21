// Checkbox: the demo (loon's follows shadcn's newer Field-based demo, so
// only the checkboxes are compared): clicking the box and its label,
// Space, Enter (which Radix ignores), the disabled one, attributes, look.
import { both, compare, each, focused, inRoot, shotRoot as shot, slots, wait } from "./lib.mjs";

const SEL = "[data-slot=checkbox], [data-slot=checkbox-indicator], [data-slot=checkbox-indicator] svg";
const states = () => [...document.querySelectorAll("[data-parity-root] [data-slot=checkbox]")].map((c) => {
  const r = c.getBoundingClientRect();
  const cs = getComputedStyle(c);
  return `${c.dataset.state} ${c.getAttribute("aria-checked")} ${c.disabled ? "disabled" : ""} ${Math.round(r.width)}x${Math.round(r.height)} bg=${cs.backgroundColor} border=${cs.borderColor} radius=${cs.borderRadius}${c === document.activeElement ? " FOCUSED" : ""}`;
});
const b = await both();
await b.open("checkbox", "Demo", "checkbox-demo");
await compare(b, "initial", slots, SEL);
await compare(b, "initial states", states);
await shot(b, "checkbox-initial");
const first = (p) => inRoot(p, "[data-slot=checkbox]");
await each(b, (p) => first(p).click());
await wait(b, 50);
await compare(b, "click 1st", states);
await compare(b, "focus", focused);
await compare(b, "checked indicator", slots, SEL);
await each(b, (p) => p.keyboard.press("Space"));
await wait(b, 50);
await compare(b, "Space", states);
await each(b, (p) => p.keyboard.press("Enter"));
await wait(b, 50);
await compare(b, "Enter (ignored)", states);
await each(b, (p) => inRoot(p, "label").click());
await wait(b, 50);
await compare(b, "click 1st label", states);
await compare(b, "focus after label", focused);
await each(b, (p) => p.keyboard.press("Tab"));
await compare(b, "Tab", focused);
await shot(b, "checkbox-after");
await each(b, (p) => inRoot(p, "[data-slot=checkbox][disabled]").click({ force: true }));
await compare(b, "click disabled", states);
await b.close();
