// Drawer: the Demo as a modal (see overlay.mjs's modalChecks), then
// dragging it by the pointer: a short drag springs back, a long one or a
// flick closes it, dragging up barely moves it; where the panel and overlay
// are meanwhile.
import { both, each, inRoot, shot, wait } from "./lib.mjs";
import { compareBy, modalChecks, timeUntil } from "./overlay.mjs";

const sel = {
  trigger: "[data-slot=drawer-trigger]",
  content: "[data-slot=drawer-content]",
  overlay: "[data-slot=drawer-overlay]",
};
const b = await both();
await b.open("drawer", "Demo", "drawer-demo");
await modalChecks(b, { ...sel, name: "demo", tabs: 5, closeButton: "[data-slot=drawer-close]" });

const panel = (p) =>
  p.evaluate((s) => {
    const c = [...document.querySelectorAll(s.content)].find((e) => e.getAttribute("data-state") !== "closed");
    if (!c) return null;
    const r = c.getBoundingClientRect();
    const o = document.querySelector(s.overlay);
    return { top: Math.round(r.top), h: Math.round(r.height), overlayOpacity: o && Number(getComputedStyle(o).opacity).toFixed(2) };
  }, sel);

const open = async () => {
  // (A drawer left stuck open by a failed drag is closed first.)
  await each(b, (p) => p.keyboard.press("Escape"));
  await wait(b, 800);
  await each(b, (p) => inRoot(p, sel.trigger).click());
  await wait(b, 800);
};
// Drags from the panel's handle area by [dy] over [steps] moves, reports
// the panel mid-drag, then lets go and reports it after [after] ms.
const drag = async (label, dy, steps, after = 800) => {
  await each(b, async (p) => {
    const r = await p.locator(sel.content).first().boundingBox();
    const x = r.x + r.width / 2, y = r.y + 8;
    await p.mouse.move(x, y);
    await p.mouse.down();
    await p.mouse.move(x, y + dy, { steps });
  });
  await compareBy(b, `${label}: mid-drag`, panel);
  await shot(b, `drawer-${label}-mid`);
  await each(b, (p) => p.mouse.up());
  await wait(b, after);
  await compareBy(b, `${label}: after letting go`, panel);
};

await open();
await compareBy(b, "open", panel);
await drag("short drag down (springs back)", 60, 10);
await drag("drag up (damped)", -80, 10);
await drag("long drag down (closes)", 250, 25);
await open();
await drag("flick down (closes)", 60, 2);
await open();
// The panel's content (not the handle): text drags too in vaul.
await each(b, async (p) => {
  const t = p.locator(`${sel.content} [data-slot=drawer-description]`).first();
  const r = await t.boundingBox();
  await p.mouse.move(r.x + 5, r.y + r.height / 2);
  await p.mouse.down();
  await p.mouse.move(r.x + 5, r.y + 200, { steps: 20 });
  await p.mouse.up();
});
await wait(b, 800);
await compareBy(b, "drag by the description (closes in vaul)", panel);
const removed = await Promise.all([b.loon.page, b.ref.page].map((p) => timeUntil(p, sel.content, null, 1500)));
console.log(`removed after: loon ${removed[0]} ref ${removed[1]}`);
await b.close();
