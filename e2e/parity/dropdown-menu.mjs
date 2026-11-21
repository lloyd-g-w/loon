// Dropdown menu: the Demo (keyboard and pointer, the "Invite users"
// submenu), Checkboxes and Radio Group examples.
import { both, compare, each, inRoot, shot, wait } from "./lib.mjs";
import { align, clipShot, describe, hover, press } from "./_menu.mjs";

const b = await both();
const T = { trigger: "button" };
const state = (label) => compare(b, label, describe, T);

await b.open("dropdown_menu", "Demo", "dropdown-menu-demo");
await align(b, "button");
await state("closed");
// Open by click.
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
await state("click open");
await clipShot(b, "dropdown-open", "button");
await press(b, "ArrowDown", T);
await press(b, "ArrowDown", T, "ArrowDown 2");
await press(b, "End", T);
await press(b, "ArrowDown", T, "ArrowDown at end (no loop)");
await press(b, "Home", T);
await press(b, "ArrowUp", T, "ArrowUp at start");
// Typeahead: single letters (Radix's search string clears after 1s), then
// a word typed quickly.
await press(b, "t", T, "typeahead t", 1100);
await press(b, "s", T, "typeahead s", 1100);
await press(b, "s", T, "typeahead s again", 1100);
await each(b, (p) => p.keyboard.type("ke", { delay: 50 }));
await press(b, "y", T, "typeahead 'key' quickly", 1100);
await press(b, "s", T, "typeahead s", 100);
await press(b, "s", T, "typeahead ss quickly (cycles)", 1100);
// The submenu by keyboard.
await press(b, "i", T, "typeahead i", 1100);
await press(b, "ArrowRight", T, "ArrowRight opens sub", 400);
await clipShot(b, "dropdown-sub", "button");
await press(b, "ArrowDown", T, "ArrowDown in sub");
await press(b, "ArrowLeft", T, "ArrowLeft closes sub", 400);
await press(b, "Enter", T, "Enter on sub trigger", 400);
await press(b, "Escape", T, "Escape closes sub", 400);
await press(b, "Escape", T, "Escape closes menu", 400);
// Keyboard open.
await press(b, "Enter", T, "Enter on trigger", 400);
await press(b, "Escape", T, "Escape", 400);
await press(b, "Space", T, "Space on trigger", 400);
await press(b, "Escape", T, "Escape", 400);
await press(b, "ArrowDown", T, "ArrowDown on trigger", 400);
await press(b, "Enter", T, "Enter selects (closes)", 400);
// Pointer.
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
await hover(b, "Billing", T);
await hover(b, "API", T, "hover disabled API");
await hover(b, "Invite users", T, "hover sub trigger", 500);
await hover(b, "Message", T, "hover into sub", 400);
await clipShot(b, "dropdown-sub-hover", "button");
await hover(b, "Team", T, "hover back to Team (sub closes)", 600);
// Pointer leaving the items to the content's padding, then outside.
await each(b, async (p) => {
  const m = await p.locator("[role=menu]").filter({ visible: true }).first().boundingBox();
  await p.mouse.move(m.x + m.width / 2, m.y + 2);
});
await wait(b, 200);
await state("pointer on content edge");
await each(b, (p) => p.mouse.move(5, 5));
await wait(b, 200);
await state("pointer outside");
await each(b, (p) => p.mouse.click(5, 450));
await wait(b, 400);
await state("outside click");
// Selecting an item with the pointer.
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
await each(b, (p) => p.locator("[role=menuitem]", { hasText: "Settings" }).filter({ visible: true }).click());
await wait(b, 400);
await state("click Settings");
// Clicking the trigger again closes.
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
await each(b, (p) => inRoot(p, "button").click({ force: true }));
await wait(b, 400);
await state("trigger click toggles closed");

// Checkboxes.
const CB = { trigger: "button" };
await b.open("dropdown_menu", "Checkboxes", "dropdown-menu-checkboxes");
await align(b, "button");
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
await compare(b, "checkboxes open", () =>
  [...document.querySelectorAll("[role=menuitemcheckbox]")].map((e) => [e.innerText.trim(), e.getAttribute("aria-checked"), e.dataset.state, e.hasAttribute("data-disabled")]),
);
await compare(b, "checkboxes describe", describe, CB);
await clipShot(b, "checkboxes", "button");
await press(b, "ArrowDown", CB);
await press(b, "Space", CB, "Space toggles (and closes)", 400);
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
await compare(b, "after Space", () =>
  [...document.querySelectorAll("[role=menuitemcheckbox]")].map((e) => [e.innerText.trim(), e.getAttribute("aria-checked")]),
);
await press(b, "Escape", CB, "Escape", 400);

// Radio group.
await b.open("dropdown_menu", "Radio Group", "dropdown-menu-radio-group");
await align(b, "button");
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
const radios = () =>
  [...document.querySelectorAll("[role=menuitemradio]")].map((e) => [e.innerText.trim(), e.getAttribute("aria-checked"), e.dataset.state]);
await compare(b, "radios open", radios);
await compare(b, "radios describe", describe, CB);
await clipShot(b, "radios", "button");
await press(b, "ArrowDown", CB);
await press(b, "ArrowDown", CB, "ArrowDown 2");
await press(b, "Enter", CB, "Enter picks", 400);
await each(b, (p) => inRoot(p, "button").click());
await wait(b, 400);
await compare(b, "radios after Enter", radios);
await b.close();
