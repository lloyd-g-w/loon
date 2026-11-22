// Navigation menu: the Demo (no viewport at this width): opening by hover
// (after a delay) and by click, moving between triggers, closing when the
// pointer leaves, the keyboard (arrows between triggers, Enter, Tab into the
// content, Escape), and the content's place and motion attributes.
import { both, compare, each, inRoot, wait } from "./lib.mjs";
import { align, clipShot } from "./_menu.mjs";

const b = await both();
const look = () => {
  const root = document.querySelector("[data-parity-root] [data-slot=navigation-menu]");
  const vis = (e) => e && e.getClientRects().length > 0;
  const triggers = [...root.querySelectorAll("[data-slot=navigation-menu-trigger]")].filter(vis);
  const tdesc = triggers.map((t) => `${t.innerText.trim()}:${t.dataset.state}/${t.getAttribute("aria-expanded")}${t.getAttribute("aria-controls") ? (document.getElementById(t.getAttribute("aria-controls")) ? "/ctl" : "/ctl-missing") : ""}`).join(" ");
  const contents = [...document.querySelectorAll("[data-slot=navigation-menu-content]")].filter(vis).map((c) => {
    const r = c.getBoundingClientRect();
    const t = triggers.find((t) => t.dataset.state === "open") ?? triggers[0];
    const tr = t.getBoundingClientRect();
    return `${c.dataset.state} motion=${c.dataset.motion ?? "-"} @${Math.round(r.left - tr.left)},${Math.round(r.top - tr.bottom)} ${Math.round(r.width)}x${Math.round(r.height)} opacity=${getComputedStyle(c).opacity}`;
  });
  const vp = document.querySelector("[data-slot=navigation-menu-viewport]");
  const f = document.activeElement;
  return {
    root: `${root.dataset.orientation ?? "-"} viewport=${root.dataset.viewport}`,
    triggers: tdesc,
    contents,
    viewport: vis(vp) ? `${vp.dataset.state} ${Math.round(vp.getBoundingClientRect().width)}x${Math.round(vp.getBoundingClientRect().height)}` : null,
    focus: f ? `${f.tagName.toLowerCase()}${f.dataset.slot ? "." + f.dataset.slot : ""} "${(f.innerText || "").trim().split("\n")[0].slice(0, 20)}"` : null,
  };
};
const state = (label) => compare(b, label, look);
const trigger = (p, name) => inRoot(p, `[data-slot=navigation-menu-trigger]:has-text("${name}")`);
const hoverTrigger = (name) =>
  each(b, async (p) => {
    const box = await trigger(p, name).boundingBox();
    await p.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 4 });
  });

await b.open("navigation_menu", "Demo", "navigation-menu-demo");
await align(b, "[data-slot=navigation-menu]");
await state("closed");
await hoverTrigger("Getting started");
await wait(b, 100);
await state("hover Getting started 100ms (before the delay)");
await wait(b, 300);
await state("hover Getting started 400ms");
await clipShot(b, "nav-getting-started", "[data-slot=navigation-menu]", "[data-slot=navigation-menu-content]");
await hoverTrigger("Components");
await wait(b, 50);
await state("hover Components (switches at once)");
await wait(b, 400);
await state("Components settled");
await clipShot(b, "nav-components", "[data-slot=navigation-menu]", "[data-slot=navigation-menu-content]");
// Into the content: stays open.
await each(b, async (p) => {
  const c = p.locator("[data-slot=navigation-menu-content]").filter({ visible: true }).first();
  const box = await c.boundingBox();
  await p.mouse.move(box.x + 40, box.y + 40, { steps: 6 });
});
await wait(b, 400);
await state("pointer into content");
// Away: closes after a delay.
await each(b, (p) => p.mouse.move(5, 5, { steps: 4 }));
await wait(b, 100);
await state("pointer away 100ms");
await wait(b, 500);
await state("pointer away 600ms");
// Click: opens; a second click closes (and hovering again does not reopen
// until the pointer leaves).
await each(b, (p) => trigger(p, "Components").click());
await wait(b, 400);
await state("click Components");
await clipShot(b, "nav-components-click", "[data-slot=navigation-menu]", "[data-slot=navigation-menu-content]");
await each(b, (p) => trigger(p, "Components").click());
await wait(b, 400);
await state("click Components again");
await each(b, (p) => p.mouse.move(5, 5, { steps: 4 }));
await wait(b, 500);
// Keyboard.
await each(b, (p) => trigger(p, "Getting started").focus());
await wait(b, 100);
await state("focus Getting started");
await each(b, (p) => p.keyboard.press("ArrowRight"));
await wait(b, 100);
await state("ArrowRight");
await each(b, (p) => p.keyboard.press("Enter"));
await wait(b, 400);
await state("Enter opens Components");
await each(b, (p) => p.keyboard.press("Tab"));
await wait(b, 100);
await state("Tab into content");
await each(b, (p) => p.keyboard.press("ArrowDown"));
await wait(b, 100);
await state("ArrowDown in content");
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 400);
await state("Escape");
await each(b, (p) => p.keyboard.press("End"));
await wait(b, 100);
await state("End");
await each(b, (p) => p.keyboard.press("Space"));
await wait(b, 400);
await state("Space on last trigger");
await each(b, (p) => p.keyboard.press("ArrowDown"));
await wait(b, 100);
await state("ArrowDown from trigger");
await each(b, (p) => p.keyboard.press("Shift+Tab"));
await wait(b, 100);
await state("Shift+Tab back");
await each(b, (p) => p.mouse.click(5, 5));
await wait(b, 500);
await state("outside click");
await b.close();
