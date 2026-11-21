// Parity checks: the same interactions on loon's docs example and on
// shadcn's own example (a reference app, see README.md), printing what each
// shows side by side.
//
// Environment: PLAYWRIGHT_MODULE, LOON_DOCS (default: the dune build),
// SHADCN_REF (the reference app's URL, default http://127.0.0.1:5199/),
// SHOTS (a directory for side-by-side screenshots).
process.env.LOON_DOCS ??= new URL("../../_build/default/docs/bin/site", import.meta.url).pathname;
const { serve, ready, settle } = await import("../lib.mjs");
const playwright = await import(process.env.PLAYWRIGHT_MODULE);
import { join } from "node:path";

export const refUrl = process.env.SHADCN_REF ?? "http://127.0.0.1:5199/";
export { settle };

// Opens a page each for loon and the reference, same viewport.
export async function both(engine = process.argv[2] ?? "chromium", options = {}) {
  const server = await serve();
  // Headless Chromium hides scrollbars; show them, as a desktop browser does.
  const browser = await playwright[engine].launch(
    engine === "chromium" ? { ignoreDefaultArgs: ["--hide-scrollbars"] } : {},
  );
  const make = async () => {
    const context = await browser.newContext({ viewport: { width: 1280, height: 900 }, ...options });
    const page = await context.newPage();
    const errors = [];
    page.on("pageerror", (e) => errors.push(String(e)));
    page.on("console", (m) => m.type() === "error" && errors.push(m.text()));
    return { page, errors };
  };
  const loon = await make();
  const ref = await make();
  return {
    loon,
    ref,
    // Goes to loon's example [title] on page [slug], and shadcn's example
    // [name]; returns each preview's locator.
    async open(slug, title, name) {
      await loon.page.goto(`${server.url}#/${slug}`);
      await ready(loon.page, slug);
      const ex = loon.page.locator(".docs-example", {
        has: loon.page.locator(".docs-example-title", { hasText: new RegExp(`^\\s*${title}\\s*$`) }),
      });
      const lp = ex.locator(".docs-preview").first();
      // In the middle of the window, as the reference centres its example.
      await lp.evaluate((el) => el.scrollIntoView({ block: "center" }));
      // A fresh load: the app does not always redraw on a hash change.
      await ref.page.goto("about:blank");
      await ref.page.goto(`${refUrl}#/${name}`);
      // (Its first child may be input-otp's <noscript> or the Toaster's section.)
      await ref.page.waitForSelector("[data-ref-preview] > :not(noscript, section)");
      await ref.page.evaluate(() => document.fonts.ready);
      // Scripts find the example under [data-parity-root] on both pages.
      await lp.evaluate((el) => {
        for (const old of document.querySelectorAll("[data-parity-root]")) old.removeAttribute("data-parity-root");
        el.setAttribute("data-parity-root", "");
      });
      await ref.page.evaluate(() => document.querySelector("[data-ref-preview]").setAttribute("data-parity-root", ""));
      return { l: lp, r: ref.page.locator("[data-ref-preview]") };
    },
    async close() {
      for (const [n, s] of [["loon", loon], ["ref", ref]])
        for (const e of s.errors.splice(0)) console.log(`ERROR (${n}): ${e}`);
      await browser.close();
      server.close();
    },
  };
}

let shots = 0;
export async function shot(b, name) {
  if (!process.env.SHOTS) return;
  shots += 1;
  const p = String(shots).padStart(2, "0");
  await b.loon.page.screenshot({ path: join(process.env.SHOTS, `${p}-${name}-loon.png`) });
  await b.ref.page.screenshot({ path: join(process.env.SHOTS, `${p}-${name}-ref.png`) });
}

// Runs [f] on both pages, printing the two results and whether they agree.
export async function compare(b, label, f, arg) {
  const [l, r] = await Promise.all([b.loon.page.evaluate(f, arg), b.ref.page.evaluate(f, arg)]);
  const js = (v) => JSON.stringify(v);
  if (js(l) === js(r)) console.log(`same  ${label}: ${js(l)}`);
  else console.log(`DIFF  ${label}:\n  loon: ${js(l)}\n  ref:  ${js(r)}`);
  return [l, r];
}

// Both pages at once.
export const each = (b, f) => Promise.all([f(b.loon.page, "loon"), f(b.ref.page, "ref")]);
// A locator under the example on both pages.
export const inRoot = (p, sel) => p.locator(`[data-parity-root] ${sel}`).first();
export const wait = (b, ms) => each(b, (p) => p.waitForTimeout(ms));

// (In the page.) The example's elements with a data-slot, or matching
// [selector]: their slot, role, state and ARIA attributes, and boxes
// relative to the example's first such element. Pass as compare's fn.
export function slots(selector) {
  const root = document.querySelector("[data-parity-root]");
  const els = [...root.querySelectorAll(selector ?? "[data-slot]")];
  const base = els[0]?.getBoundingClientRect() ?? { x: 0, y: 0 };
  const keep = /^(role|tabindex|disabled|data-state|data-disabled|data-orientation|data-highlighted|data-active|data-checked|data-value|data-variant|data-size|data-spacing|aria-.*|hidden|value|type|inputmode|maxlength)$/;
  return els.map((el) => {
    const r = el.getBoundingClientRect();
    const attrs = [...el.attributes]
      .filter((a) => keep.test(a.name) && !(a.name === "aria-controls" || a.name === "aria-labelledby" || a.name === "aria-describedby"))
      .map((a) => `${a.name}=${a.value}`)
      .sort()
      .join(" ");
    const box = el.getClientRects().length === 0 ? "-" : [r.x - base.x, r.y - base.y, r.width, r.height].map(Math.round).join(",");
    return `${el.dataset.slot ?? el.tagName.toLowerCase()} ${attrs} @${box}${el === document.activeElement ? " FOCUSED" : ""}`;
  });
}

// (In the page.) What has focus: its slot or tag, and text.
export function focused() {
  const el = document.activeElement;
  if (!el || el === document.body) return "body";
  const inRoot = !!el.closest("[data-parity-root]");
  return `${el.dataset.slot ?? el.tagName.toLowerCase()}${el.id && !/^(radix|_r_|:r)/.test(el.id) ? "" : ""} "${(el.innerText ?? el.value ?? "").trim().slice(0, 30)}"${inRoot ? "" : " (outside)"} fv=${el.matches(":focus-visible")}`;
}

// Gives the reference's preview the size and padding of loon's, so that
// w-full examples lay out the same.
export async function matchPreview(b) {
  const s = await b.loon.page.evaluate(() => {
    const el = document.querySelector("[data-parity-root]");
    const cs = getComputedStyle(el);
    return { width: el.getBoundingClientRect().width, padding: cs.padding, minHeight: el.getBoundingClientRect().height };
  });
  await b.ref.page.evaluate((s) => {
    const el = document.querySelector("[data-parity-root]");
    Object.assign(el.style, { width: `${s.width}px`, padding: s.padding, minHeight: `${s.minHeight}px`, margin: "0 auto", boxSizing: "border-box" });
  }, s);
}

// Screenshots of just the two examples (their previews), NN-name-{loon,ref}.png.
export async function shotRoot(b, name) {
  if (!process.env.SHOTS) return;
  shots += 1;
  const p = String(shots).padStart(2, "0");
  for (const [who, s] of [["loon", b.loon], ["ref", b.ref]])
    await s.page.locator("[data-parity-root]").screenshot({ path: join(process.env.SHOTS, `${p}-${name}-${who}.png`) });
}
