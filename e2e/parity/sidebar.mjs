// Sidebar: loon's Demo (sidebar-07 in a frame) against shadcn's sidebar-07 in
// the same frame (ref/src/parity/sidebar-demo.tsx): the trigger, Ctrl+B, the
// rail, the collapsed icon mode's widths and tooltips, the collapsible
// sections, and the mobile sheet (a narrow viewport).
import { both, compare, each, inRoot, shot, wait } from "./lib.mjs";

const state = () => {
  const root = document.querySelector("[data-parity-root] [data-slot=sidebar-wrapper]");
  const rr = root.getBoundingClientRect();
  const rel = (el) => {
    if (!el) return null;
    const r = el.getBoundingClientRect();
    return [r.left - rr.left, r.top - rr.top, r.width, r.height].map(Math.round).join(",");
  };
  const sb = document.querySelector("[data-parity-root] [data-slot=sidebar]");
  const a = document.activeElement;
  const mobile = document.querySelector("[data-mobile=true][data-slot=sidebar]");
  const tip = document.querySelector("[data-slot=tooltip-content]");
  return {
    sidebar: sb && {
      state: sb.dataset.state,
      collapsible: sb.dataset.collapsible,
      variant: sb.dataset.variant,
      side: sb.dataset.side,
      gap: rel(sb.querySelector("[data-slot=sidebar-gap]")),
      container: rel(sb.querySelector("[data-slot=sidebar-container]")),
    },
    inset: rel(root.querySelector("[data-slot=sidebar-inset]")),
    trigger: rel(root.querySelector("[data-slot=sidebar-trigger]")),
    playground: rel([...root.querySelectorAll("[data-sidebar=menu-button]")].find((e) => e.textContent.includes("Playground"))),
    tooltips: [...document.querySelectorAll("[data-slot=tooltip-content]")].length,
    groupLabels: [...root.querySelectorAll("[data-slot=sidebar-group-label]")].map((l) => getComputedStyle(l).opacity),
    mobile: mobile && {
      state: mobile.closest("[data-state]")?.dataset.state,
      box: (() => { const r = mobile.getBoundingClientRect(); return [r.left, r.top, r.width, r.height].map(Math.round).join(","); })(),
    },
    tooltip: tip && [tip.textContent, tip.dataset.side, tip.dataset.state],
    focus: a?.dataset?.slot ?? a?.tagName,
    cookie: document.cookie.includes("sidebar_state") ? document.cookie.match(/sidebar_state=\w+/)[0] : null,
  };
};
const settle = (b) => wait(b, 400);

const b = await both();
await b.open("sidebar", "Demo", "parity-sidebar-demo");
await compare(b, "initial", state);
await each(b, (p) => inRoot(p, "[data-slot=sidebar-trigger]").click());
await settle(b);
await compare(b, "trigger: collapsed", state);
await shot(b, "sidebar-collapsed");
// Hover a menu button while collapsed: its tooltip.
await each(b, (p) => p.locator("[data-parity-root] [data-sidebar=menu-button]", { hasText: "Playground" }).first().hover());
await wait(b, 800);
await compare(b, "collapsed: hover a button", state);
await shot(b, "sidebar-collapsed-tooltip");
await each(b, (p) => p.mouse.move(900, 500));
await settle(b);
await each(b, (p) => p.keyboard.press("Control+b"));
await settle(b);
await compare(b, "Ctrl+B: expanded", state);
await each(b, (p) => p.keyboard.press("Control+b"));
await settle(b);
await compare(b, "Ctrl+B: collapsed", state);
// The rail toggles it back.
await each(b, async (p) => {
  const r = await inRoot(p, "[data-slot=sidebar-rail]").boundingBox();
  await p.mouse.click(r.x + r.width / 2, r.y + r.height / 2);
});
await settle(b);
await compare(b, "rail click: expanded", state);
// A collapsible section: open and closed.
await each(b, (p) => p.locator("[data-parity-root] [data-sidebar=menu-button]", { hasText: "Models" }).first().click());
await settle(b);
await compare(b, "Models opened", state);
await shot(b, "sidebar-models-open");
// Tab order from the trigger backwards into the sidebar.
await each(b, (p) => inRoot(p, "[data-slot=sidebar-trigger]").focus());
await each(b, (p) => p.keyboard.press("Shift+Tab"));
await compare(b, "Shift+Tab from the trigger", state);
await b.close();

// Mobile: the sidebar is a sheet.
const m = await both("chromium", { viewport: { width: 390, height: 800 } });
await m.open("sidebar", "Demo", "parity-sidebar-demo");
await compare(m, "mobile: initial", state);
await each(m, (p) => inRoot(p, "[data-slot=sidebar-trigger]").click());
await wait(m, 700);
await compare(m, "mobile: opened", state);
await shot(m, "sidebar-mobile-open");
await each(m, (p) => p.keyboard.press("Escape"));
await wait(m, 700);
await compare(m, "mobile: Escape", state);
await each(m, (p) => p.keyboard.press("Control+b"));
await wait(m, 700);
await compare(m, "mobile: Ctrl+B opens", state);
await each(m, (p) => p.mouse.click(370, 400));
await wait(m, 700);
await compare(m, "mobile: outside click", state);
await m.close();
