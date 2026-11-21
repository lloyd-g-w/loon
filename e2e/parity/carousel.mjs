// Carousel: Demo, Sizes, Orientation against shadcn's carousel-demo,
// carousel-size, carousel-orientation: the buttons, the arrow keys, dragging
// with the pointer, the ends' disabled buttons, and where the slides end up.
import { both, compare, each, inRoot, shotRoot as shot, wait } from "./lib.mjs";

const b = await both();
const state = () => {
  const root = document.querySelector("[data-parity-root] [data-slot=carousel]");
  const vp = root.querySelector("[data-slot=carousel-content]");
  const items = [...root.querySelectorAll("[data-slot=carousel-item]")];
  const vr = vp.getBoundingClientRect();
  // Which slides are (mostly) in view, and the first one's offset in the viewport.
  const shown = items
    .map((it, i) => [i + 1, it.getBoundingClientRect()])
    .filter(([, r]) => r.left >= vr.left - 2 && r.right <= vr.right + 2 && r.top >= vr.top - 2 && r.bottom <= vr.bottom + 2)
    .map(([i]) => i);
  const first = items[0].getBoundingClientRect();
  const btn = (s) => {
    const el = root.querySelector(`[data-slot=carousel-${s}]`);
    if (!el) return null;
    const r = el.getBoundingClientRect();
    return { disabled: el.disabled, dx: Math.round(r.left - vr.left), dy: Math.round(r.top - vr.top), w: Math.round(r.width) };
  };
  const a = document.activeElement;
  return {
    shown,
    offset: [Math.round(first.left - vr.left), Math.round(first.top - vr.top)],
    itemSize: [Math.round(first.width), Math.round(first.height)],
    prev: btn("previous"),
    next: btn("next"),
    region: [root.getAttribute("role"), root.getAttribute("aria-roledescription")],
    slide: [items[0].getAttribute("role"), items[0].getAttribute("aria-roledescription")],
    focus: a?.dataset?.slot ?? a?.tagName,
  };
};
const settle = () => wait(b, 900);

for (const [title, name] of [["Demo", "carousel-demo"], ["Sizes", "carousel-size"], ["Orientation", "carousel-orientation"]]) {
  await b.open("carousel", title, name);
  await settle();
  await compare(b, `${title}: initial`, state);
  for (let i = 0; i < 5; i++) {
    await each(b, (p) => inRoot(p, "[data-slot=carousel-next]").click({ timeout: 2000 }).catch(() => {}));
    await settle();
    await compare(b, `${title}: next ${i + 1}`, state);
  }
  await shot(b, `carousel-${name}-end`);
  await each(b, (p) => inRoot(p, "[data-slot=carousel-previous]").click());
  await settle();
  await compare(b, `${title}: previous`, state);
  // Keys: on the focused carousel (Radix-free; shadcn's onKeyDownCapture).
  await each(b, (p) => inRoot(p, "[data-slot=carousel-previous]").focus());
  const back = title === "Orientation" ? "ArrowUp" : "ArrowLeft";
  const fwd = title === "Orientation" ? "ArrowDown" : "ArrowRight";
  for (const k of [back, back, back, fwd, "ArrowLeft", "ArrowRight"]) {
    await each(b, (p) => p.keyboard.press(k));
    await settle();
    await compare(b, `${title}: key ${k}`, state);
  }
  // Drag the slides with the mouse.
  await each(b, async (p) => {
    const vp = inRoot(p, "[data-slot=carousel-content]");
    const r = await vp.boundingBox();
    const [x, y] = [r.x + r.width / 2, r.y + r.height / 2];
    const [dx, dy] = title === "Orientation" ? [0, -r.height * 0.6] : [-r.width * 0.6, 0];
    await p.mouse.move(x, y);
    await p.mouse.down();
    for (let s = 1; s <= 10; s++) await p.mouse.move(x + (dx * s) / 10, y + (dy * s) / 10);
    await p.mouse.up();
  });
  await settle();
  await compare(b, `${title}: drag forward`, state);
  // A short drag snaps back.
  await each(b, async (p) => {
    const vp = inRoot(p, "[data-slot=carousel-content]");
    const r = await vp.boundingBox();
    const [x, y] = [r.x + r.width / 2, r.y + r.height / 2];
    await p.mouse.move(x, y);
    await p.mouse.down();
    for (let s = 1; s <= 5; s++) await p.mouse.move(x + (title === "Orientation" ? 0 : 2 * s), y + (title === "Orientation" ? 2 * s : 0));
    await p.mouse.up();
  });
  await settle();
  await compare(b, `${title}: short drag`, state);
  await shot(b, `carousel-${name}-dragged`);
}
await b.close();
