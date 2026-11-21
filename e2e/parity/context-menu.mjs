// Context menu: the Demo, opened by right-clicking the area (positions are
// relative to the area's corner), its keyboard, the "More Tools" submenu,
// re-opening elsewhere, and closing.
import { both, compare, each, inRoot, wait } from "./lib.mjs";
import { align, clipShot, describe, hover, press } from "./_menu.mjs";

const b = await both();
const A = { trigger: "[data-slot=context-menu-trigger]" };
const state = (label) => compare(b, label, describe, A);
const rightClick = (dx, dy) =>
  each(b, async (p) => {
    const box = await inRoot(p, A.trigger).boundingBox();
    await p.mouse.click(box.x + dx, box.y + dy, { button: "right" });
  });

await b.open("context_menu", "Demo", "context-menu-demo");
await align(b, A.trigger);
await compare(b, "trigger", () => {
  const t = document.querySelector("[data-parity-root] [data-slot=context-menu-trigger]");
  return [t.tagName, t.dataset.state, t.getAttribute("tabindex"), t.style.webkitTouchCallout, getComputedStyle(t).userSelect];
});
await state("closed");
await rightClick(40, 30);
await wait(b, 50);
await state("right click (50ms, animating)");
await wait(b, 350);
await state("right click open");
await clipShot(b, "context-open", A.trigger);
await press(b, "ArrowDown", A);
await press(b, "ArrowDown", A, "ArrowDown skips disabled");
await press(b, "ArrowDown", A, "ArrowDown 3");
await press(b, "ArrowRight", A, "ArrowRight opens sub", 400);
await clipShot(b, "context-sub", A.trigger);
await press(b, "End", A, "End in sub");
await press(b, "ArrowLeft", A, "ArrowLeft back", 400);
await press(b, "End", A, "End");
await press(b, "Home", A, "Home");
await press(b, "r", A, "typeahead r", 1100);
// Escape closes; focus goes back to the page.
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 30);
await state("Escape (30ms, exit animation)");
await wait(b, 400);
await state("Escape closed");
// Pointer: hover, the submenu, moving into it diagonally.
await rightClick(40, 30);
await wait(b, 400);
await hover(b, "Reload", A);
await hover(b, "More Tools", A, "hover More Tools", 500);
await hover(b, "Developer Tools", A, "hover into sub", 400);
await clipShot(b, "context-sub-hover", A.trigger);
await hover(b, "Back", A, "hover Back (sub closes)", 600);
// Right-clicking again elsewhere moves the menu.
await rightClick(250, 120);
await wait(b, 400);
await state("right click elsewhere in the area");
// Near the window's edge the menu flips.
await each(b, (p) => p.mouse.click(5, 5));
await wait(b, 400);
await state("outside click closes");
// The checkbox item: selecting closes the menu.
await rightClick(40, 30);
await wait(b, 400);
await each(b, (p) => p.locator("[role=menuitemcheckbox]", { hasText: "Show Full URLs" }).click());
await wait(b, 400);
await state("click checkbox item closes");
// A right click outside the area while open closes it (and the browser's
// own menu would open).
await rightClick(40, 30);
await wait(b, 400);
await each(b, (p) => p.mouse.click(5, 450, { button: "right" }));
await wait(b, 400);
await state("right click outside");
await b.close();
