// node e2e/shot.mjs OUT.png [WIDTHxHEIGHT] [dark] [#hash]: a full-page
// screenshot of the built docs site, for looking at while working on it.
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE);
const site = process.env.LOON_DOCS ?? new URL("../_build/default/docs/bin/site", import.meta.url).pathname;
const [out, size = "1280x900", scheme = "light", hash = ""] = process.argv.slice(2);
const [width, height] = size.split("x").map(Number);
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width, height }, colorScheme: scheme });
const errors = [];
page.on("pageerror", (e) => errors.push(String(e)));
page.on("console", (m) => { if (m.type() === "error") errors.push(m.text()); });
await page.goto(`file://${site}/index.html${hash}`);
await page.waitForSelector(".loon");
await page.screenshot({ path: out, fullPage: true });
for (const e of errors) console.log("error:", e);
await browser.close();
