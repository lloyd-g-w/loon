// Scroll area: Demo and Horizontal against shadcn's scroll-area-demo and
// scroll-area-horizontal-demo: the scrollbars appearing on hover (Radix's
// type="hover"), wheel scrolling, the thumb's size and position, dragging the
// thumb, clicking the track, and hiding again after the pointer leaves.
import { both, compare, each, inRoot, shotRoot as shot, wait } from "./lib.mjs";

const b = await both();
const state = () => {
  const root = document.querySelector("[data-parity-root] [data-slot=scroll-area]");
  const vp = root.querySelector("[data-slot=scroll-area-viewport]");
  const rr = root.getBoundingClientRect();
  const rel = (el) => {
    const r = el.getBoundingClientRect();
    return [r.left - rr.left, r.top - rr.top, r.width, r.height].map(Math.round).join(",");
  };
  const bars = [...root.querySelectorAll("[data-slot=scroll-area-scrollbar]")].map((s) => {
    const t = s.querySelector("[data-slot=scroll-area-thumb]");
    const cs = getComputedStyle(s);
    return {
      o: s.dataset.orientation,
      state: s.dataset.state,
      shown: cs.display !== "none" && cs.visibility !== "hidden" && Number(cs.opacity) > 0,
      bar: rel(s),
      thumb: t && rel(t),
    };
  });
  return {
    root: `${Math.round(rr.width)}x${Math.round(rr.height)}`,
    scroll: [Math.round(vp.scrollLeft), Math.round(vp.scrollTop)],
    bars,
  };
};

for (const [title, name, dx, dy] of [
  ["Demo", "scroll-area-demo", 0, 120],
  ["Horizontal", "scroll-area-horizontal-demo", 120, 0],
]) {
  await b.open("scroll_area", title, name);
  await compare(b, `${title}: initial`, state);
  const centre = async (p) => {
    const r = await inRoot(p, "[data-slot=scroll-area]").boundingBox();
    return [r.x + r.width / 2, r.y + r.height / 2, r];
  };
  await each(b, async (p) => {
    const [x, y] = await centre(p);
    await p.mouse.move(x, y);
  });
  await wait(b, 300);
  await compare(b, `${title}: hover`, state);
  for (let i = 0; i < 3; i++) {
    await each(b, (p) => p.mouse.wheel(dx, dy));
    await wait(b, 200);
    await compare(b, `${title}: wheel ${i + 1}`, state);
  }
  await shot(b, `scroll-area-${name}-scrolled`);
  // Drag the thumb back to the start.
  await each(b, async (p) => {
    const t = await inRoot(p, `[data-slot=scroll-area-scrollbar][data-orientation=${dy ? "vertical" : "horizontal"}] [data-slot=scroll-area-thumb]`).boundingBox();
    const [x, y] = [t.x + t.width / 2, t.y + t.height / 2];
    await p.mouse.move(x, y);
    await p.mouse.down();
    for (let s = 1; s <= 10; s++) await p.mouse.move(x - (dx ? 30 * s : 0), y - (dy ? 30 * s : 0));
    await p.mouse.up();
  });
  await wait(b, 200);
  await compare(b, `${title}: thumb dragged back`, state);
  // Click the track near the end.
  await each(b, async (p) => {
    const s = await inRoot(p, `[data-slot=scroll-area-scrollbar][data-orientation=${dy ? "vertical" : "horizontal"}]`).boundingBox();
    await p.mouse.click(s.x + (dx ? s.width - 6 : s.width / 2), s.y + (dy ? s.height - 6 : s.height / 2));
  });
  await wait(b, 300);
  await compare(b, `${title}: track click near the end`, state);
  await each(b, (p) => p.mouse.move(2, 2));
  await wait(b, 100);
  await compare(b, `${title}: left (before the hide delay)`, state);
  await wait(b, 900);
  await compare(b, `${title}: left (after the hide delay)`, state);
  // Keyboard: the viewport is not focusable in Radix; Tab from the page.
  await shot(b, `scroll-area-${name}-left`);
}
await b.close();
