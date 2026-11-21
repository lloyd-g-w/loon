// Slider: the demo (one thumb, 0-100): keyboard steps (arrows, Shift,
// PageUp/Down, Home/End), clicking the track, dragging the thumb, and the
// thumb's and range's positions relative to the track.
import { both, compare, each, focused, inRoot, matchPreview, shotRoot as shot, slots, wait } from "./lib.mjs";

const SEL = "[data-slot=slider], [data-slot=slider-track], [data-slot=slider-range], [data-slot=slider-thumb], input";
const pos = () => {
  const root = document.querySelector("[data-parity-root]");
  const track = root.querySelector("[data-slot=slider-track]").getBoundingClientRect();
  const range = root.querySelector("[data-slot=slider-range]").getBoundingClientRect();
  return [...root.querySelectorAll("[data-slot=slider-thumb]")].map((t) => {
    const r = t.getBoundingClientRect();
    return `value=${t.getAttribute("aria-valuenow")} thumb-centre=${Math.round(r.x + r.width / 2 - track.x)} range=${Math.round(range.x - track.x)}..${Math.round(range.right - track.x)}/${Math.round(track.width)}${t === document.activeElement ? " FOCUSED" : ""}`;
  });
};
const b = await both();
await b.open("slider", "Demo", "slider-demo");
await matchPreview(b);
await wait(b, 100);
await compare(b, "initial", slots, SEL);
await compare(b, "initial position", pos);
await shot(b, "slider-initial");
await each(b, (p) => inRoot(p, "[data-slot=slider-thumb]").focus());
for (const key of ["ArrowRight", "ArrowUp", "ArrowLeft", "ArrowDown", "Shift+ArrowRight", "PageUp", "PageDown", "End", "ArrowRight", "Home", "ArrowLeft"]) {
  await each(b, (p) => p.keyboard.press(key));
  await wait(b, 30);
  await compare(b, key, pos);
}
// Click on the track at 75%.
await each(b, async (p) => {
  const t = await inRoot(p, "[data-slot=slider-track]").boundingBox();
  await p.mouse.click(t.x + t.width * 0.75, t.y + t.height / 2);
});
await wait(b, 50);
await compare(b, "click at 75%", pos);
await compare(b, "focus after click", focused);
// Drag the thumb to 20%, and past the end.
await each(b, async (p) => {
  const th = await inRoot(p, "[data-slot=slider-thumb]").boundingBox();
  const t = await inRoot(p, "[data-slot=slider-track]").boundingBox();
  await p.mouse.move(th.x + th.width / 2, th.y + th.height / 2);
  await p.mouse.down();
  await p.mouse.move(t.x + t.width * 0.2, t.y, { steps: 5 });
});
await wait(b, 30);
await compare(b, "dragging to 20%", pos);
await compare(b, "dragging: data attrs", slots, "[data-slot=slider-thumb], [data-slot=slider]");
await each(b, async (p) => {
  const t = await inRoot(p, "[data-slot=slider-track]").boundingBox();
  await p.mouse.move(t.x + t.width + 200, t.y + 100, { steps: 5 });
  await p.mouse.up();
});
await wait(b, 30);
await compare(b, "dragged past the end", pos);
await shot(b, "slider-end");
await b.close();
