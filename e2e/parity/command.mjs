// Command: the Demo (the selected item on load, arrows skipping disabled
// items, Home/End, filtering and the empty state, groups hiding, pointer
// selection) and the Dialog (Ctrl/⌘+J, Escape, focus).
import { both, compare, each, inRoot, wait } from "./lib.mjs";
import { clipShot } from "./_menu.mjs";

const b = await both();
const look = () => {
  const root = document.querySelector("[data-parity-root] [data-slot=command], [role=dialog] [data-slot=command]");
  if (!root) return { root: null, focus: document.activeElement?.tagName };
  const input = root.querySelector("[data-slot=command-input]");
  const list = root.querySelector("[data-slot=command-list]");
  const vis = (e) => e.getClientRects().length > 0;
  const sel = root.querySelector("[data-slot=command-item][data-selected=true]");
  const groups = [...root.querySelectorAll("[data-slot=command-group]")].filter(vis).map((g) => {
    const heading = g.querySelector("[cmdk-group-heading]")?.innerText ?? g.firstElementChild?.innerText;
    return `${heading}:${[...g.querySelectorAll("[data-slot=command-item]")].filter(vis).length}`;
  });
  const empty = root.querySelector("[data-slot=command-empty]");
  const r = root.getBoundingClientRect();
  const lr = list.getBoundingClientRect();
  return {
    selected: sel ? `${sel.innerText.split("\n")[0]} aria-selected=${sel.getAttribute("aria-selected")} disabled=${sel.dataset.disabled}` : null,
    groups: groups.join(" "),
    separators: [...root.querySelectorAll("[data-slot=command-separator]")].filter(vis).length,
    empty: empty && vis(empty) ? empty.innerText : null,
    input: [input.value, input.getAttribute("role"), input.getAttribute("aria-expanded"), input.getAttribute("aria-autocomplete"), input.getAttribute("aria-activedescendant") ? (document.getElementById(input.getAttribute("aria-activedescendant")) === sel ? "ad-ok" : "ad-wrong") : "no-ad"].join(" "),
    list: `${list.getAttribute("role")} ${Math.round(lr.height)}h scroll=${Math.round(list.scrollTop)}/${list.scrollHeight - list.clientHeight}`,
    size: `${Math.round(r.width)}x${Math.round(r.height)}`,
    focus: document.activeElement === input ? "input" : `${document.activeElement?.tagName} ${document.activeElement?.dataset.slot ?? ""}`,
  };
};
const state = (label) => compare(b, label, look);
const key = async (k, label = k, ms = 100) => {
  await each(b, (p) => p.keyboard.press(k));
  await wait(b, ms);
  await state(label);
};
const type = async (text, label = `type ${JSON.stringify(text)}`) => {
  await each(b, (p) => p.keyboard.type(text));
  await wait(b, 150);
  await state(label);
};

await b.open("command", "Demo", "command-demo");
await state("initial");
await each(b, (p) => inRoot(p, "[data-slot=command-input]").click());
await state("focus input");
await clipShot(b, "command-demo", "[data-slot=command]", "[data-slot=command]");
await key("ArrowDown");
await key("ArrowDown", "ArrowDown skips disabled");
await key("End");
await key("ArrowDown", "ArrowDown at end (no loop)");
await key("Home");
await key("ArrowUp", "ArrowUp at start");
await type("pro");
await clipShot(b, "command-filter", "[data-slot=command]", "[data-slot=command]");
await each(b, (p) => p.keyboard.press("Control+a"));
await type("zzz", "no match");
await clipShot(b, "command-empty", "[data-slot=command]", "[data-slot=command]");
await each(b, (p) => p.keyboard.press("Control+a"));
await type("cal", "type cal (disabled Calculator matches)");
await each(b, (p) => p.keyboard.press("Control+a"));
await each(b, (p) => p.keyboard.press("Backspace"));
await wait(b, 100);
await state("cleared");
// Pointer: hovering selects; leaving keeps it; disabled items do not.
const hoverItem = (text) =>
  each(b, (p) => inRoot(p, `[data-slot=command-item]:has-text("${text}")`).hover({ force: true }));
await hoverItem("Billing");
await wait(b, 100);
await state("hover Billing");
await hoverItem("Calculator");
await wait(b, 100);
await state("hover disabled Calculator");
await each(b, (p) => p.mouse.move(5, 5));
await wait(b, 100);
await state("pointer away");
await each(b, (p) => inRoot(p, `[data-slot=command-item]:has-text("Profile")`).click());
await wait(b, 100);
await state("click Profile");

// The dialog.
await b.open("command", "Dialog", "parity-command-dialog");
await each(b, (p) => p.mouse.click(5, 5));
await each(b, (p) => p.keyboard.press("Control+j"));
await wait(b, 400);
await state("Ctrl+J opens");
await compare(b, "dialog", () => {
  const d = document.querySelector("[role=dialog]");
  if (!d) return null;
  const r = d.getBoundingClientRect();
  return [d.dataset.state, d.dataset.slot, Math.round(r.width), Math.round(r.height), Math.round(r.left + r.width / 2 - innerWidth / 2), Math.round(r.top), document.body.style.pointerEvents, getComputedStyle(document.body).overflow, d.querySelector("[data-slot=dialog-close]") ? "close-button" : "no-close"];
});
await clipShot(b, "command-dialog", "[role=dialog]", "[role=dialog]");
await key("ArrowDown", "dialog ArrowDown");
await type("se", "dialog type se");
await key("Enter", "dialog Enter");
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 400);
await compare(b, "Escape closes", () => [!!document.querySelector("[role=dialog]"), document.activeElement?.tagName]);
await each(b, (p) => p.keyboard.press("Meta+j"));
await wait(b, 400);
await compare(b, "Meta+J opens", () => !!document.querySelector("[role=dialog]"));
await each(b, (p) => p.keyboard.press("Control+j"));
await wait(b, 400);
await compare(b, "Ctrl+J again toggles closed", () => !!document.querySelector("[role=dialog]"));
await b.close();
