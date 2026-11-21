// Helpers the menu-like parity scripts share (dropdown-menu, context-menu,
// menubar, combobox, command, navigation-menu): a description of the open
// menus, the highlighted item and the focus, comparable across loon and
// shadcn (positions relative to the trigger, rounded).
import { compare, each } from "./lib.mjs";

// Evaluated in the page. [trigger]: a selector for the trigger under the
// example root (or null); [content]: the selector of open contents.
export function describe({ trigger, content = "[role=menu]" }) {
  const round = (v) => Math.round(v);
  const t = trigger ? document.querySelector(`[data-parity-root] ${trigger}`) : null;
  const tr = t?.getBoundingClientRect();
  const desc = (el) => {
    if (!el || el === document.body) return "body";
    const text = (el.getAttribute("aria-label") || el.innerText || el.value || "").trim().split("\n")[0].slice(0, 24);
    return `${el.tagName.toLowerCase()}${el.getAttribute("role") ? `[${el.getAttribute("role")}]` : ""}${el.dataset.slot ? `.${el.dataset.slot}` : ""} "${text}"`;
  };
  // One line per open content: slot, state, side/align, position relative
  // to the trigger's bottom-left (x,y) and size, item count, broken ids.
  const menus = [...document.querySelectorAll(content)]
    .filter((m) => m.getClientRects().length > 0)
    .map((m) => {
      const r = m.getBoundingClientRect();
      const pos = tr ? `@${round(r.left - tr.left)},${round(r.top - tr.bottom)}` : "";
      const lb = m.getAttribute("aria-labelledby");
      const broken = lb && !document.getElementById(lb) ? " labelledby-missing" : "";
      return `${m.dataset.slot ?? m.getAttribute("role")} ${m.dataset.state ?? "-"} ${m.dataset.side ?? "-"}/${m.dataset.align ?? "-"} ${pos} ${round(r.width)}x${round(r.height)} ${m.querySelectorAll("[role^=menuitem],[role=option]").length}items${broken}`;
    });
  let trig = null;
  if (t) {
    const c = t.getAttribute("aria-controls");
    trig = [t.dataset.state, t.getAttribute("aria-expanded"), t.getAttribute("aria-haspopup"), c ? (document.getElementById(c) ? "controls-ok" : "controls-missing") : "no-controls", t.hasAttribute("data-highlighted") ? "hl" : ""].join(" ").trim();
  }
  return {
    trigger: trig,
    menus,
    hl: [...document.querySelectorAll("[data-highlighted]")].map((e) => e.innerText.trim().split("\n")[0]).join("|"),
    focus: desc(document.activeElement),
  };
}

// Presses [key] on both pages, waits, and compares the description.
export async function press(b, key, args, label = key, ms = 250) {
  await each(b, (p) => p.keyboard.press(key));
  await each(b, (p) => p.waitForTimeout(ms));
  return compare(b, label, describe, args);
}

// Moves the pointer onto the item named [text] (the visible one) on both
// pages.
export async function hover(b, text, args, label = `hover ${text}`, ms = 300) {
  await each(b, async (p) => {
    const item = p.locator("[role^=menuitem],[role=option]", { hasText: text }).filter({ visible: true }).first();
    const box = await item.boundingBox();
    if (!box) return;
    await p.mouse.move(box.x + box.width / 2 - 10, box.y + box.height / 2, { steps: 3 });
    await p.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 2 });
  });
  await each(b, (p) => p.waitForTimeout(ms));
  return compare(b, label, describe, args);
}

// Scrolls loon's page so that the element [selector] in its example is at
// the same place in the window as in the reference (where the room around a
// trigger decides which side a menu opens on).
export async function align(b, selector) {
  const at = (p) => p.locator(`[data-parity-root] ${selector}`).first().evaluate((e) => e.getBoundingClientRect().top);
  const [l, r] = await Promise.all([at(b.loon.page), at(b.ref.page)]);
  await b.loon.page.evaluate((dy) => {
    let el = document.querySelector("[data-parity-root]");
    while (el && el !== document.documentElement) {
      const s = getComputedStyle(el);
      if (/(auto|scroll)/.test(s.overflowY) && el.scrollHeight > el.clientHeight) break;
      el = el.parentElement;
    }
    (el ?? document.scrollingElement).scrollBy(0, dy);
  }, l - r);
  await b.loon.page.waitForTimeout(100);
  const now = await at(b.loon.page);
  if (Math.abs(now - r) > 2) console.log(`note: could not align ${selector} (loon ${Math.round(now)}, ref ${Math.round(r)})`);
}

// Screenshots of the region around the example's [selector] and the open
// contents (SHOTS only): NN-name-{loon,ref}.png.
let clips = 0;
export async function clipShot(b, name, selector, content = "[role=menu],[role=listbox],[role=dialog]") {
  if (!process.env.SHOTS) return;
  clips += 1;
  const n = String(clips).padStart(2, "0");
  await each(b, async (p, who) => {
    const r = await p.evaluate(
      ({ selector, content }) => {
        const els = [document.querySelector(`[data-parity-root] ${selector}`), ...document.querySelectorAll(content)].filter(
          (e) => e && e.getClientRects().length > 0,
        );
        const rs = els.map((e) => e.getBoundingClientRect());
        const x = Math.max(0, Math.min(...rs.map((r) => r.left)) - 16);
        const y = Math.max(0, Math.min(...rs.map((r) => r.top)) - 16);
        const w = Math.min(innerWidth - x, Math.max(...rs.map((r) => r.right)) + 16 - x);
        const h = Math.min(innerHeight - y, Math.max(...rs.map((r) => r.bottom)) + 16 - y);
        return { x, y, width: w, height: h };
      },
      { selector, content },
    );
    await p.screenshot({ path: `${process.env.SHOTS}/${n}-${name}-${who}.png`, clip: r });
  });
}
