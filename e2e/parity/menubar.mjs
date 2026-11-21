// Menubar: the Demo. Roving focus over the triggers, opening by click and
// keyboard, moving between menus with the arrows (and by hovering once one
// is open), the Share submenu, Escape and outside clicks.
import { both, compare, each, inRoot, wait } from "./lib.mjs";
import { align, clipShot, describe, hover, press } from "./_menu.mjs";

const b = await both();
const A = { trigger: "[data-slot=menubar]" };
const state = (label) => compare(b, label, describe, A);
const bar = () => {
  const ts = [...document.querySelectorAll("[data-parity-root] [data-slot=menubar-trigger]")];
  return ts.map((t) => `${t.innerText}:${t.dataset.state}/${t.getAttribute("aria-expanded")}/${t.tabIndex}${t.hasAttribute("data-highlighted") ? "/hl" : ""}`).join(" ");
};
const barState = async (label) => {
  await compare(b, `${label} (bar)`, bar);
  await state(label);
};
const trigger = (p, name) => inRoot(p, `[data-slot=menubar-trigger]:text-is("${name}")`);

await b.open("menubar", "Demo", "menubar-demo");
await align(b, "[data-slot=menubar]");
await compare(b, "root", () => {
  const r = document.querySelector("[data-parity-root] [data-slot=menubar]");
  return [r.getAttribute("role"), r.getAttribute("aria-orientation"), r.getBoundingClientRect().height];
});
await barState("closed");
// Click File.
await each(b, (p) => trigger(p, "File").click());
await wait(b, 300);
await barState("click File");
await clipShot(b, "menubar-file", "[data-slot=menubar]");
await press(b, "ArrowDown", A);
await press(b, "ArrowDown", A, "ArrowDown 2");
await press(b, "ArrowDown", A, "ArrowDown 3 (skips disabled)");
await press(b, "ArrowRight", A, "ArrowRight opens Share", 400);
await press(b, "ArrowRight", A, "ArrowRight in sub (next menu?)", 400);
await barState("after ArrowRight in sub");
await press(b, "ArrowLeft", A, "ArrowLeft", 400);
await barState("after ArrowLeft");
await press(b, "ArrowLeft", A, "ArrowLeft again", 400);
await barState("after ArrowLeft again");
await press(b, "ArrowLeft", A, "ArrowLeft wraps", 400);
await barState("after ArrowLeft wraps");
// Hovering another trigger while one is open switches menus.
await each(b, (p) => trigger(p, "Edit").hover());
await wait(b, 300);
await barState("hover Edit while open");
await hover(b, "Find", A, "hover Find", 500);
await clipShot(b, "menubar-edit-find", "[data-slot=menubar]");
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 300);
await barState("Escape (in sub)");
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 300);
await barState("Escape again");
// Keyboard from the bar.
await each(b, (p) => trigger(p, "File").focus());
await press(b, "ArrowRight", A, "bar ArrowRight (roving)");
await barState("bar ArrowRight");
await press(b, "End", A, "bar End");
await barState("bar End");
await press(b, "ArrowRight", A, "bar ArrowRight loops");
await barState("bar ArrowRight loops");
await press(b, "Enter", A, "Enter opens", 300);
await barState("Enter opens");
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 300);
await press(b, "ArrowDown", A, "ArrowDown on trigger opens", 300);
await barState("ArrowDown on trigger");
await press(b, "ArrowUp", A, "ArrowUp (no loop)");
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 300);
await press(b, "Space", A, "Space opens", 300);
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 300);
// Hovering a trigger while closed does not open.
await each(b, (p) => trigger(p, "View").hover());
await wait(b, 300);
await barState("hover View while closed");
// Click toggles; outside click closes.
await each(b, (p) => trigger(p, "View").click());
await wait(b, 300);
await clipShot(b, "menubar-view", "[data-slot=menubar]");
await each(b, (p) => trigger(p, "View").click());
await wait(b, 300);
await barState("click View again (toggles closed)");
await each(b, (p) => trigger(p, "Profiles").click());
await wait(b, 300);
await clipShot(b, "menubar-profiles", "[data-slot=menubar]");
await each(b, (p) => p.mouse.click(5, 5));
await wait(b, 400);
await barState("outside click");
await b.close();
