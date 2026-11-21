// scratch probe (not committed)
process.env.LOON_DOCS ??= new URL("../_build/default/docs/bin/site", import.meta.url).pathname;
const { open, ready, serve } = await import("./lib.mjs");
const [hash, script, out, size = "1280x900", scheme = "light"] = process.argv.slice(2);
const [width, height] = size.split("x").map(Number);
const server = await serve();
const { browser, page, errors } = await open("chromium", { colorScheme: scheme, permissions: false });
await page.setViewportSize({ width, height });
await page.goto(`${server.url}${hash}`);
await ready(page);
const fn = new Function("page", `return (async () => { ${script} })()`);
const r = await fn(page);
if (r !== undefined) console.log(typeof r === "string" ? r : JSON.stringify(r, null, 1));
if (out) await page.screenshot({ path: out });
for (const e of errors) console.log("error:", e);
console.log("url:", page.url().replace(server.url, ""));
await browser.close();
server.close();
