// Resizable: Demo, Demo with handle, Vertical against shadcn's examples:
// dragging handles with the mouse (and its data-separator states), the
// keyboard (arrows, Home/End, Enter), and the panels' sizes after.
import { both, compare, each, inRoot, shotRoot as shot, wait } from "./lib.mjs";

const b = await both();
const state = () => {
  const root = document.querySelector("[data-parity-root] [data-slot=resizable-panel-group]");
  const gr = root.getBoundingClientRect();
  const panels = [...root.querySelectorAll("[data-slot=resizable-panel]")].map((p) => {
    const r = p.getBoundingClientRect();
    return `${Math.round(r.width)}x${Math.round(r.height)}`;
  });
  const handles = [...root.querySelectorAll("[data-slot=resizable-handle]")].map((h) => ({
    sep: h.dataset.separator,
    now: h.getAttribute("aria-valuenow"),
    min: h.getAttribute("aria-valuemin"),
    max: h.getAttribute("aria-valuemax"),
  }));
  const a = document.activeElement;
  return {
    group: `${Math.round(gr.width)}x${Math.round(gr.height)}`,
    panels,
    handles,
    focus: a?.dataset?.slot ?? a?.tagName,
    cursor: getComputedStyle(document.body).cursor,
  };
};

const handle = (p, i) => p.locator("[data-parity-root] [data-slot=resizable-handle]").nth(i);

for (const [title, name] of [
  ["Demo", "resizable-demo"],
  ["Demo with handle", "resizable-demo-with-handle"],
  ["Vertical", "resizable-vertical"],
]) {
  await b.open("resizable", title, name);
  await compare(b, `${title}: initial`, state);
  const vertical = title === "Vertical";
  // Hover the first handle, then drag it.
  await each(b, async (p) => {
    const r = await handle(p, 0).boundingBox();
    await p.mouse.move(r.x + r.width / 2, r.y + r.height / 2);
  });
  await wait(b, 100);
  await compare(b, `${title}: hover handle`, state);
  await each(b, (p) => p.mouse.down());
  await wait(b, 50);
  await compare(b, `${title}: pointer down`, state);
  await each(b, async (p) => {
    const r = await handle(p, 0).boundingBox();
    const [x, y] = [r.x + r.width / 2, r.y + r.height / 2];
    for (let s = 1; s <= 10; s++) await p.mouse.move(x + (vertical ? 0 : 6 * s), y + (vertical ? 4 * s : 0));
  });
  await compare(b, `${title}: dragging +60/+40`, state);
  await each(b, (p) => p.mouse.up());
  await wait(b, 50);
  await compare(b, `${title}: released`, state);
  // Drag far past the end: the panels' min sizes (if any) hold.
  await each(b, async (p) => {
    const r = await handle(p, 0).boundingBox();
    const [x, y] = [r.x + r.width / 2, r.y + r.height / 2];
    await p.mouse.move(x, y);
    await p.mouse.down();
    for (let s = 1; s <= 10; s++) await p.mouse.move(x + (vertical ? 0 : 100 * s), y + (vertical ? 100 * s : 0));
    await p.mouse.up();
  });
  await wait(b, 50);
  await compare(b, `${title}: dragged past the end`, state);
  await each(b, (p) => p.mouse.move(5, 5));
  await wait(b, 50);
  await compare(b, `${title}: pointer away`, state);
  // Keyboard.
  await each(b, (p) => handle(p, 0).focus());
  for (const k of ["Home", "ArrowRight", "ArrowDown", "ArrowLeft", "ArrowUp", "End", "Enter", "Enter", "Shift+ArrowLeft"]) {
    await each(b, (p) => p.keyboard.press(k));
    await wait(b, 50);
    await compare(b, `${title}: key ${k}`, state);
  }
  await shot(b, `resizable-${name}`);
}
await b.close();
