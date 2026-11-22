// node e2e/styles-shot.mjs OUTDIR [light|dark] [item]: the Create page's
// preview in every style (OUTDIR/<style>-<scheme>.png), for comparing
// with ui.shadcn.com/create. Needs what shot.mjs needs.
process.env.LOON_DOCS ??= new URL("../_build/default/docs/bin/site", import.meta.url).pathname;
const { open, ready, serve } = await import("./lib.mjs");
const [out, scheme = "light", item = "preview-02"] = process.argv.slice(2);
const styles = ["vega", "nova", "maia", "lyra", "mira", "luma", "sera", "rhea"];
const server = await serve();
const { browser, page, errors } = await open("chromium", { colorScheme: scheme, permissions: false });
await page.setViewportSize({ width: 1600, height: 1000 });
await page.goto(`${server.url}#/create?item=${item}`);
await ready(page);
for (const style of styles) {
  await page.click("[data-picker=style]");
  await page.click(`[data-value=${style}]`);
  await page.keyboard.press("Escape");
  await page.waitForTimeout(400);
  await page.screenshot({ path: `${out}/${style}-${scheme}.png` });
}
for (const e of errors) console.log("error:", e);
await browser.close();
server.close();
