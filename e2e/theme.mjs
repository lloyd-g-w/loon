// The mode switcher, what it changes and that a reload keeps it; and that
// the system's dark preference is the default.
import { checkErrors, open, ready, run, screenshot } from "./lib.mjs";

const theme = (page) =>
  page.evaluate(() => {
    const dark = document.documentElement.classList.contains("dark");
    const bg = getComputedStyle(document.querySelector("[data-slot=layout]")).backgroundColor;
    return `html ${dark ? "dark" : "light"}, background ${bg}`;
  });
const toggle = "[data-docs=mode-switcher]";

// Every code surface on the page (fenced blocks, the install command, the
// previews' code, inline code): the darkest and lightest background's
// relative luminance, and the highlighted tokens under 3:1 contrast with
// the background they sit on.
const code = (page) =>
  page.evaluate(() => {
    const parse = (c) => {
      const m = c.match(/[\d.]+/g).map(Number);
      if (c.startsWith("oklch")) return { l: (m[0] > 1 ? m[0] / 100 : m[0]) ** 3, a: m[3] ?? 1 };
      const [r, g, b] = m
        .slice(0, 3)
        .map((v) => ((v /= 255) <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
      return { l: 0.2126 * r + 0.7152 * g + 0.0722 * b, a: m[3] ?? 1 };
    };
    const bg = (e) => {
      for (; e; e = e.parentElement) {
        const c = parse(getComputedStyle(e).backgroundColor);
        if (c.a > 0.5) return c.l;
      }
      return 1;
    };
    const shown = (sel) => [...document.querySelectorAll(sel)].filter((e) => e.offsetParent);
    const lum = shown("figure[data-rehype-pretty-code-figure], [data-page] :not(pre) > code").map(bg);
    const tokens = shown("[data-page] .hl, [data-page] [class^=hl-], [data-page] [class*=' hl-']");
    const faint = tokens.filter((t) => {
      const [a, b] = [parse(getComputedStyle(t).color).l, bg(t)];
      return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05) < 3;
    });
    const r = (x) => x.toFixed(2);
    return `${lum.length > 10 ? "many" : lum.length} surfaces, background luminance ${r(Math.min(...lum))}..${r(Math.max(...lum))}, tokens under 3:1: ${faint.length}`;
  });

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(`${url}#/button`);
  await ready(page, "button");
  console.log(`default: ${await theme(page)}`);
  console.log(`toggle: ${await page.getAttribute(toggle, "title")}`);
  await page.click(toggle);
  await page.waitForSelector("html.dark");
  console.log(`toggled: ${await theme(page)}`);
  console.log(`dark code: ${await code(page)}`);
  await screenshot(page, "dark");

  await page.reload();
  await ready(page);
  console.log(`reloaded: ${await theme(page)}`);
  await page.click(toggle);
  await page.waitForSelector("html:not(.dark)");
  await page.reload();
  await ready(page);
  console.log(`light again, reloaded: ${await theme(page)}`);
  console.log(`light code: ${await code(page)}`);
  checkErrors(errors, "theme");
  await browser.close();

  // A system in dark mode, nothing stored.
  const dark = await open(engine, { colorScheme: "dark" });
  await dark.page.goto(url);
  await ready(dark.page);
  console.log(`system dark: ${await theme(dark.page)}`);
  await dark.page.goto(`${url}#/radio_group`);
  await ready(dark.page, "radio_group");
  console.log(`system dark code: ${await code(dark.page)}`);
  checkErrors(dark.errors, "system dark");
  await dark.browser.close();
});
