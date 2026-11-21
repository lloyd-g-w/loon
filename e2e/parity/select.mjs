// Select: the Scrollable (item-aligned, a long list) and Popper examples.
import { both, compare, each, inRoot, settle, shot } from "./lib.mjs";

const b = await both();
const state = () => {
  const t = document.querySelector("[data-parity-root] [data-slot=select-trigger]");
  const c = document.querySelector("[data-slot=select-content]");
  const vp = c?.querySelector("[data-radix-select-viewport]");
  const r = (el) => { if (!el) return null; const x = el.getBoundingClientRect(); return [x.x, x.y, x.width, x.height].map(Math.round).join(","); };
  return {
    trigger: [t.dataset.state, t.getAttribute("aria-expanded")],
    content: r(c),
    wrapper: r(c?.parentElement),
    up: !!c?.querySelector("[data-slot=select-scroll-up-button]:not([hidden])"),
    down: !!c?.querySelector("[data-slot=select-scroll-down-button]:not([hidden])"),
    scrollbar: vp ? vp.offsetWidth - vp.clientWidth : null,
    scrollTop: vp ? Math.round(vp.scrollTop) : null,
    focus: document.activeElement?.innerText?.trim().slice(0, 30),
  };
};
const t = await b.open("select", "Scrollable", "select-scrollable");
await each(b, (p) => inRoot(p, "[data-slot=select-trigger]").click());
await each(b, (p) => p.waitForTimeout(400));
await compare(b, "open", state);
await shot(b, "select-open");
for (let i = 0; i < 8; i++) {
  await each(b, async (p) => { await p.mouse.move(640, 450); await p.mouse.wheel(0, 200); await p.waitForTimeout(100); });
  await compare(b, `wheel ${i}`, state);
}
await shot(b, "select-bottom");
await each(b, (p) => p.keyboard.press("Home"));
await each(b, (p) => p.waitForTimeout(200));
await compare(b, "Home", state);
await each(b, (p) => p.keyboard.press("End"));
await each(b, (p) => p.waitForTimeout(200));
await compare(b, "End", state);
await each(b, (p) => p.keyboard.press("Enter"));
await each(b, (p) => p.waitForTimeout(300));
await compare(b, "Enter", state);
await each(b, (p) => p.keyboard.press("Enter"));
await each(b, (p) => p.waitForTimeout(400));
await compare(b, "reopen", state);
await shot(b, "select-reopen");
await b.close();
