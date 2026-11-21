// What the overlay scripts (popover, dialog, tooltip, ...) compare: the
// trigger's and the content's attributes, the content's place relative to
// the trigger, where the focus is, and whether the page is scroll-locked.
import { compare, each, inRoot, shot, wait } from "./lib.mjs";

// Evaluated in the page: [trigger] is a selector under the example,
// [content] one anywhere in the document (portalled).
export function overlayState({ trigger, content }) {
  const t = document.querySelector(`[data-parity-root] ${trigger}`);
  const cs = [...document.querySelectorAll(content)];
  const c = cs.find((el) => el.getAttribute("data-state") !== "closed") ?? cs[0];
  const r = (el) => el && el.getBoundingClientRect();
  const attrs = (el, names) =>
    el ? Object.fromEntries(names.filter((n) => el.hasAttribute(n)).map((n) => [n, el.getAttribute(n)])) : null;
  const ids = (v) => (v == null ? v : v.replace(/[^ ]+/g, "<id>"));
  const ta = attrs(t, ["data-state", "aria-expanded", "aria-haspopup", "aria-controls", "aria-describedby", "type"]);
  if (ta) for (const k of ["aria-controls", "aria-describedby"]) if (k in ta) ta[k] = ids(ta[k]);
  const ca = attrs(c, ["data-state", "data-side", "data-align", "role", "aria-modal", "aria-labelledby", "aria-describedby", "tabindex"]);
  if (ca) for (const k of ["aria-labelledby", "aria-describedby"]) if (k in ca) ca[k] = ids(ca[k]);
  const tr = r(t);
  const cr = r(c);
  const a = document.activeElement;
  const describe = (el) => {
    if (!el || el === document.body) return "body";
    const slot = el.getAttribute("data-slot");
    const text = (el.innerText ?? "").trim().split("\n")[0].slice(0, 25);
    return `${el.tagName.toLowerCase()}${slot ? `[${slot}]` : ""}${el.tagName === "INPUT" ? `#${el.id || el.name}` : ""} "${text}"`;
  };
  const style = getComputedStyle(document.body);
  return {
    trigger: ta,
    count: cs.length,
    content: ca,
    rel:
      tr && cr
        ? {
            dx: Math.round(cr.left - tr.left),
            dy: Math.round(cr.top - tr.top),
            w: Math.round(cr.width),
            h: Math.round(cr.height),
          }
        : null,
    focus: describe(a),
    focusInContent: !!(c && a && c.contains(a)),
    lock: {
      overflow: style.overflow,
      pointerEvents: style.pointerEvents,
    },
  };
}

// A compare of overlayState on both pages.
export const state = (b, label, sel) => compare(b, label, overlayState, sel);

// The content's position relative to the trigger, rounded to [tol] px.
export function near([l, r], tol = 3) {
  return l && r && l.rel && r.rel && Math.abs(l.rel.dx - r.rel.dx) <= tol && Math.abs(l.rel.dy - r.rel.dy) <= tol;
}

// Every running animation on elements matching [sel] finished (Web
// Animations API), or none left.
export const animationsDone = (b, sel) =>
  each(b, (p) =>
    p.evaluate(
      (s) =>
        Promise.all(
          [...document.querySelectorAll(s)].flatMap((el) => el.getAnimations({ subtree: true }).filter((a) => a.effect?.getComputedTiming().endTime !== Infinity).map((a) => a.finished.catch(() => {}))),
        ),
      sel,
    ),
  );

export const press = (b, key) => each(b, (p) => p.keyboard.press(key));

// A click outside the overlay: on the example's preview, near its corner.
export const outside = (b) =>
  each(b, (p) => p.locator("[data-parity-root]").click({ position: { x: 6, y: 6 }, force: true }));

// [action] on both pages, then: how long until no element matches
// [content] (ms, to 50, by animation frames, up to [max]), and whether one
// showed data-state="closed" meanwhile (an exit animation).
export async function closing(b, label, content, action, max = 1500) {
  const run = async (p) => {
    await p.evaluate(([sel, max]) => {
      window.__closing = new Promise((resolve) => {
        const start = performance.now();
        let closed = false;
        const tick = () => {
          const els = document.querySelectorAll(sel);
          if ([...els].some((e) => e.getAttribute("data-state") === "closed")) closed = true;
          const t = performance.now() - start;
          if (els.length === 0 || t > max)
            resolve({ gone: els.length === 0 ? Math.round(t / 50) * 50 : null, closedState: closed });
          else requestAnimationFrame(tick);
        };
        // Started by the action's first frame.
        window.__closingStart = () => requestAnimationFrame(tick);
      });
    }, [content, max]);
    await action(p);
    return p.evaluate(() => (window.__closingStart(), window.__closing));
  };
  const [l, r] = await Promise.all([run(b.loon.page), run(b.ref.page)]);
  const js = JSON.stringify;
  console.log(`${js(l) === js(r) ? "same " : "DIFF "} ${label}: loon ${js(l)} ref ${js(r)}`);
  return [l, r];
}

// Evaluated in the page: a modal's content (dialog, alert dialog, sheet,
// drawer) as the window shows it, its overlay, the names its aria
// attributes give it, and the page's scroll lock.
export function modalState({ content, overlay }) {
  const c = [...document.querySelectorAll(content)].find((e) => e.getAttribute("data-state") === "open");
  const o = [...document.querySelectorAll(overlay)].find((e) => e.getAttribute("data-state") === "open");
  const rect = (el) => {
    if (!el) return null;
    const r = el.getBoundingClientRect();
    return [r.left, r.top, r.width, r.height].map(Math.round).join(",");
  };
  const text = (ids) =>
    ids && ids.split(" ").map((id) => document.getElementById(id)?.textContent.trim().slice(0, 30)).join("|");
  const html = getComputedStyle(document.documentElement);
  const body = getComputedStyle(document.body);
  return {
    content: rect(c),
    role: c?.getAttribute("role"),
    labelledBy: text(c?.getAttribute("aria-labelledby")),
    describedBy: text(c?.getAttribute("aria-describedby")),
    overlay: rect(o),
    overlayBg: o && getComputedStyle(o).backgroundColor,
    scrollLocked: [html.overflow, body.overflow].some((v) => v === "hidden" || v === "clip"),
    bodyPointerEvents: body.pointerEvents,
  };
}

// Where focus is, by tag, slot and text.
export function focusName() {
  const a = document.activeElement;
  if (!a || a === document.body) return "body";
  const slot = a.getAttribute("data-slot");
  const text = (a.innerText || a.value || a.getAttribute("aria-label") || "").trim().split("\n")[0].slice(0, 25);
  return `${a.tagName.toLowerCase()}${slot ? `[${slot}]` : ""} "${text}"`;
}

// The checks every modal shares: open by click, Enter and Space; focus in
// and Tab cycling; Escape, the close button and an outside click (which
// [dismissOutside] says closes it); focus back on the trigger; the exit
// animation; the page's scroll lock.
export async function modalChecks(b, { trigger, content, overlay, dismissOutside = true, tabs = 6, closeButton, name }) {
  const t = (p) => inRoot(p, trigger);
  const mstate = (label) => compare(b, `${name}: ${label}`, modalState, { content, overlay });
  const focus = (label) => compare(b, `${name}: ${label} focus`, focusName);
  await mstate("closed");
  await each(b, (p) => t(p).click());
  await settled(b);
  await mstate("click opens");
  await focus("opened");
  await shotIf(b, `${name}-open`);
  const seq = [[], []];
  for (let i = 0; i < tabs; i++) {
    await press(b, "Tab");
    const [l, r] = await each(b, (p) => p.evaluate(focusName));
    seq[0].push(l);
    seq[1].push(r);
  }
  const js = JSON.stringify;
  console.log(`${js(seq[0]) === js(seq[1]) ? "same " : "DIFF "} ${name}: Tab x${tabs}:\n  loon: ${js(seq[0])}\n  ref:  ${js(seq[1])}`);
  await press(b, "Shift+Tab");
  await focus("Shift+Tab");
  // The page under it does not scroll.
  const scroll = await each(b, async (p) => {
    const before = await p.evaluate(() => scrollY);
    await p.mouse.move(5, 5);
    await p.mouse.wheel(0, 300);
    await p.waitForTimeout(200);
    return (await p.evaluate(() => scrollY)) - before;
  });
  console.log(`${scroll[0] === scroll[1] ? "same " : "DIFF "} ${name}: page scrolled by the wheel over the overlay: loon ${scroll[0]} ref ${scroll[1]}`);
  await closing(b, `${name}: Escape, removed after`, content, (p) => p.keyboard.press("Escape"));
  await focus("after Escape");
  await mstate("after Escape");
  await press(b, "Enter");
  await settled(b);
  await mstate("Enter opens");
  await press(b, "Escape");
  await settled(b);
  await press(b, "Space");
  await settled(b);
  await mstate("Space opens");
  await closing(b, `${name}: outside click (${dismissOutside ? "closes" : "stays"})`, content, clickOutside(content), 900);
  await mstate("after outside click");
  await focus("after outside click");
  if (closeButton) {
    const [l] = await each(b, (p) => p.evaluate((c) => !!document.querySelector(c), content));
    if (!l) { await each(b, (p) => t(p).click()); await settled(b); }
    await closing(b, `${name}: close button`, content, (p) => p.locator(closeButton).first().click());
    await focus("after the close button");
  }
}

// Waits for the animations on the page to end (the sheets slide for 500ms).
const settled = async (b) => {
  await wait(b, 50);
  await each(b, (p) => p.evaluate(() => Promise.all(document.getAnimations().filter((a) => a.effect?.getComputedTiming().endTime !== Infinity).map((a) => a.finished.catch(() => {})))));
  await wait(b, 50);
};

// A click at a corner of the window that [content] does not cover.
const clickOutside = (content) => async (p) => {
  const [x, y] = await p.evaluate((sel) => {
    const c = document.querySelector(sel)?.getBoundingClientRect();
    const pts = [[5, 5], [innerWidth - 5, innerHeight - 5], [innerWidth - 5, 5], [5, innerHeight - 5]];
    return pts.find(([x, y]) => !c || x < c.left || x > c.right || y < c.top || y > c.bottom) ?? pts[0];
  }, content);
  await p.mouse.click(x, y);
};

let shotN = 0;
async function shotIf(b, name) {
  if (!process.env.SHOTS) return;
  shotN += 1;
  const { join } = await import("node:path");
  const p = String(shotN).padStart(2, "0");
  await b.loon.page.screenshot({ path: join(process.env.SHOTS, `m${p}-${name}-loon.png`) });
  await b.ref.page.screenshot({ path: join(process.env.SHOTS, `m${p}-${name}-ref.png`) });
}

// As lib.mjs's compare, but [f] runs here, given the page.
export async function compareBy(b, label, f) {
  const [l, r] = await Promise.all([f(b.loon.page), f(b.ref.page)]);
  const js = (v) => JSON.stringify(v);
  if (js(l) === js(r)) console.log(`same  ${label}: ${js(l)}`);
  else console.log(`DIFF  ${label}:\n  loon: ${js(l)}\n  ref:  ${js(r)}`);
  return [l, r];
}

// Polls until [sel] matches an element with data-state matching [state]
// (a RegExp) or none at all when [state] is null; the ms it took, or null
// after [max].
export async function timeUntil(p, sel, state, max = 2000) {
  return p.evaluate(
    ([sel, state, max]) =>
      new Promise((resolve) => {
        const re = state && new RegExp(state);
        const start = performance.now();
        const tick = () => {
          const els = [...document.querySelectorAll(sel)];
          const ok = re ? els.some((e) => re.test(e.getAttribute("data-state") ?? "")) : els.length === 0;
          const t = performance.now() - start;
          if (ok) resolve(Math.round(t / 25) * 25);
          else if (t > max) resolve(null);
          else requestAnimationFrame(tick);
        };
        tick();
      }),
    [sel, state, max],
  );
}

// Hover/focus floating content (tooltip, hover card): the open and close
// delays by hover, moving onto the content, opening on keyboard focus,
// Escape, and where it sits.
export async function hoverChecks(b, { name, trigger, content, arrow }) {
  const t = (p) => inRoot(p, trigger);
  const rel = (p) =>
    p.evaluate(
      ([trigger, content, arrow]) => {
        const tr = document.querySelector(`[data-parity-root] ${trigger}`).getBoundingClientRect();
        const c = document.querySelector(content);
        if (!c) return null;
        const r = c.getBoundingClientRect();
        const a = arrow && document.querySelector(arrow)?.getBoundingClientRect();
        const attrs = {};
        for (const at of c.attributes)
          if (/^(data-state|data-side|data-align|role|id)$/.test(at.name)) attrs[at.name] = at.name === "id" ? "<id>" : at.value;
        const trEl = document.querySelector(`[data-parity-root] ${trigger}`);
        const tAttrs = {};
        for (const at of trEl.attributes) if (/^(data-state|aria-)/.test(at.name)) tAttrs[at.name] = /^aria-(describedby|controls)/.test(at.name) ? "<id>" : at.value;
        return {
          trigger: tAttrs,
          content: attrs,
          dx: Math.round(r.left - tr.left), dy: Math.round(r.top - tr.top), w: Math.round(r.width), h: Math.round(r.height),
          arrow: a ? { dx: Math.round(a.left - tr.left), dy: Math.round(a.top - tr.top), w: Math.round(a.width) } : null,
          describedByOk: !!document.getElementById(trEl.getAttribute("aria-describedby") ?? "x"),
        };
      },
      [trigger, content, arrow],
    );
  await each(b, (p) => p.mouse.move(2, 2));
  await wait(b, 400);
  // Hover: time to open.
  const opened = await Promise.all(
    [b.loon.page, b.ref.page].map(async (p) => {
      const box = await t(p).boundingBox();
      await p.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
      return timeUntil(p, content, "open|delayed-open|instant-open", 2000);
    }),
  );
  console.log(`${Math.abs((opened[0] ?? 1e9) - (opened[1] ?? 1e9)) <= 100 ? "same " : "DIFF "} ${name}: hover opens after (ms): loon ${opened[0]} ref ${opened[1]}`);
  await wait(b, 400);
  await compareBy(b, `${name}: open by hover`, rel);
  await shot(b, `${name}-hover`);
  // Onto the content: stays open.
  await each(b, async (p) => {
    const tb = await t(p).boundingBox();
    const cb = await p.locator(content).first().boundingBox();
    if (!cb) return;
    await p.mouse.move(tb.x + tb.width / 2, tb.y + tb.height / 2);
    await p.mouse.move(cb.x + cb.width / 2, cb.y + cb.height / 2, { steps: 8 });
  });
  await wait(b, 800);
  await compareBy(b, `${name}: pointer moved onto the content`, (p) => p.evaluate((s) => document.querySelector(s)?.getAttribute("data-state") ?? null, content));
  // Leave: time to close.
  const closed = await Promise.all(
    [b.loon.page, b.ref.page].map(async (p) => {
      await p.mouse.move(2, 2);
      return timeUntil(p, content, null, 2000);
    }),
  );
  console.log(`${Math.abs((closed[0] ?? 1e9) - (closed[1] ?? 1e9)) <= 100 ? "same " : "DIFF "} ${name}: leave removes after (ms): loon ${closed[0]} ref ${closed[1]}`);
  // Keyboard focus opens (focus-visible only).
  await each(b, (p) => t(p).evaluate((el) => el.blur()));
  await each(b, async (p) => {
    await t(p).focus();
    // A Tab-like focus: press Shift+Tab then Tab so :focus-visible holds.
    await p.keyboard.press("Shift+Tab");
    await p.keyboard.press("Tab");
  });
  const kb = await Promise.all([b.loon.page, b.ref.page].map((p) => timeUntil(p, content, "open", 2000)));
  console.log(`${Math.abs((kb[0] ?? 1e9) - (kb[1] ?? 1e9)) <= 100 ? "same " : "DIFF "} ${name}: keyboard focus opens after (ms): loon ${kb[0]} ref ${kb[1]}`);
  await wait(b, 300);
  await compareBy(b, `${name}: focus`, (p) => p.evaluate(focusName));
  await press(b, "Escape");
  await wait(b, 400);
  await compareBy(b, `${name}: after Escape`, rel);
  await compareBy(b, `${name}: after Escape focus`, (p) => p.evaluate(focusName));
  // Hover then press on the trigger.
  await each(b, async (p) => {
    await p.mouse.move(2, 2);
    await p.waitForTimeout(200);
    const box = await t(p).boundingBox();
    await p.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
    await p.waitForTimeout(900);
    await p.mouse.down();
    await p.mouse.up();
    await p.waitForTimeout(400);
  });
  await compareBy(b, `${name}: after a click on the trigger`, rel);
  await each(b, (p) => p.mouse.move(2, 2));
  await wait(b, 900);
}
