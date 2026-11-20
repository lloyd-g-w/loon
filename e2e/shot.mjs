// node e2e/shot.mjs OUT.png [WIDTHxHEIGHT] [dark] [#hash]: a full-page
// screenshot of the built docs site (served over http, as fonts need), for
// looking at while working on it. Needs PLAYWRIGHT_MODULE and
// PLAYWRIGHT_BROWSERS_PATH; LOON_DOCS defaults to the dune build.
process.env.LOON_DOCS ??= new URL("../_build/default/docs/bin/site", import.meta.url).pathname;
const { open, ready, serve } = await import("./lib.mjs");
const [out, size = "1280x900", scheme = "light", hash = ""] = process.argv.slice(2);
const [width, height] = size.split("x").map(Number);
const server = await serve();
const { browser, page, errors } = await open("chromium", { colorScheme: scheme, permissions: false });
await page.setViewportSize({ width, height });
await page.goto(`${server.url}${hash}`);
await ready(page);
await page.screenshot({ path: out, fullPage: true });
for (const e of errors) console.log("error:", e);
await browser.close();
server.close();
