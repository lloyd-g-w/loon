// Combobox: the Demo (a Popover holding a Command): opening by click and
// keyboard, the popover's place, filtering, selecting by Enter and click
// (toggling off), focus back on the trigger, Escape, outside click; and the
// Popover and Dropdown menu examples' opening.
import { both, compare, each, inRoot, wait } from "./lib.mjs";
import { align, clipShot } from "./_menu.mjs";

const b = await both();
const look = () => {
  const t = document.querySelector("[data-parity-root] button[role=combobox], [data-parity-root] [data-slot=popover-trigger]");
  const c = document.querySelector("[data-slot=popover-content]");
  const tr = t.getBoundingClientRect();
  const vis = (e) => e && e.getClientRects().length > 0;
  let content = null;
  if (vis(c)) {
    const r = c.getBoundingClientRect();
    const input = c.querySelector("[data-slot=command-input]");
    const sel = c.querySelector("[data-slot=command-item][data-selected=true]");
    content = {
      at: `${c.dataset.state} ${c.dataset.side}/${c.dataset.align} @${Math.round(r.left - tr.left)},${Math.round(r.top - tr.bottom)} ${Math.round(r.width)}x${Math.round(r.height)}`,
      items: [...c.querySelectorAll("[data-slot=command-item]")].filter(vis).map((i) => `${i.innerText.trim()}${i.querySelector("svg.opacity-100, svg:not(.opacity-0)") && getComputedStyle(i.querySelector("svg")).opacity === "1" ? "✓" : ""}`).join(","),
      selected: sel?.innerText.trim() ?? null,
      empty: vis(c.querySelector("[data-slot=command-empty]")) ? c.querySelector("[data-slot=command-empty]").innerText : null,
      input: input?.value,
    };
  }
  const f = document.activeElement;
  return {
    trigger: `${t.innerText.trim()} | ${t.dataset.state} expanded=${t.getAttribute("aria-expanded")} haspopup=${t.getAttribute("aria-haspopup")} controls=${t.getAttribute("aria-controls") ? (document.getElementById(t.getAttribute("aria-controls")) ? "ok" : "missing") : "-"}`,
    content,
    focus: f === t ? "trigger" : f?.dataset.slot ?? f?.tagName,
  };
};
const state = (label) => compare(b, label, look);
const key = async (k, label = k, ms = 150) => {
  await each(b, (p) => p.keyboard.press(k));
  await wait(b, ms);
  await state(label);
};
const trigger = (p) => inRoot(p, ":is(button[role=combobox], [data-slot=popover-trigger])");

await b.open("combobox", "Demo", "combobox-demo");
await align(b, "button[role=combobox]");
await state("closed");
await each(b, (p) => trigger(p).click());
await wait(b, 50);
await state("click (50ms)");
await wait(b, 300);
await state("click open");
await clipShot(b, "combobox-open", "button", "[data-slot=popover-content]");
await key("ArrowDown");
await key("End");
await each(b, (p) => p.keyboard.type("n"));
await wait(b, 150);
await state("type n");
await key("Enter", "Enter selects", 400);
await clipShot(b, "combobox-selected", "button", "[data-slot=popover-content]");
await key("Enter", "Enter on trigger reopens", 400);
await state("reopened (selected item first?)");
await key("Enter", "Enter again toggles off", 400);
await key("Space", "Space opens", 400);
await each(b, (p) => p.keyboard.type("zzz"));
await wait(b, 150);
await state("no match");
await clipShot(b, "combobox-empty", "button", "[data-slot=popover-content]");
await key("Escape", "Escape", 400);
await each(b, (p) => trigger(p).click());
await wait(b, 400);
await state("reopen (input cleared?)");
await each(b, (p) => p.locator("[data-slot=command-item]", { hasText: "Remix" }).click());
await wait(b, 400);
await state("click Remix");
await each(b, (p) => trigger(p).click());
await wait(b, 400);
await each(b, (p) => p.mouse.click(5, 5));
await wait(b, 400);
await state("outside click");
// Clicking into another field while open: the popover closes and that
// field keeps the focus (Radix does not return it to the trigger).
await each(b, (p) =>
  p.evaluate(() => {
    const i = document.createElement("input");
    i.id = "parity-outside-input";
    i.style.cssText = "position:fixed;left:8px;bottom:8px;z-index:1";
    document.body.append(i);
  }),
);
await each(b, (p) => trigger(p).click());
await wait(b, 400);
await each(b, (p) => p.locator("#parity-outside-input").click());
await wait(b, 400);
await compare(b, "click into an outside input", () => [document.activeElement?.id, !!document.querySelector("[data-slot=popover-content]")]);
// Tab from the input leaves the popover (non-modal).
await each(b, (p) => trigger(p).click());
await wait(b, 400);
await key("Tab", "Tab in popover", 300);

await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 400);
await b.open("combobox", "Popover", "combobox-popover");
await align(b, "[data-slot=popover-trigger]");
await each(b, (p) => trigger(p).click());
await wait(b, 400);
await state("popover example open");
await clipShot(b, "combobox-popover", "[data-slot=popover-trigger]", "[data-slot=popover-content]");
await key("Enter", "popover example Enter", 400);

await b.open("combobox", "Dropdown menu", "combobox-dropdown-menu");
await compare(b, "dropdown example", () => document.querySelector("[data-parity-root]").innerText);
await each(b, (p) => inRoot(p, "[data-slot=dropdown-menu-trigger]").click());
await wait(b, 400);
await clipShot(b, "combobox-dropdown", "[data-slot=dropdown-menu-trigger]", "[role=menu]");
await each(b, (p) => p.keyboard.press("ArrowDown"));
await each(b, (p) => p.keyboard.press("ArrowDown"));
await each(b, (p) => p.keyboard.press("ArrowRight"));
await wait(b, 400);
await compare(b, "dropdown example sub", () => ({
  menus: [...document.querySelectorAll("[role=menu]")].map((m) => m.dataset.slot),
  focus: document.activeElement?.dataset.slot,
  ad: document.activeElement?.getAttribute("aria-activedescendant") ? "ad" : "-",
}));
await clipShot(b, "combobox-dropdown-sub", "[data-slot=dropdown-menu-trigger]", "[role=menu]");
await b.close();
