// What the e2e scripts share: the site served over http (fonts and
// clipboards need a real origin), a browser, console errors, screenshots.
//
// Environment: PLAYWRIGHT_MODULE, LOON_DOCS (the built site), and
// optionally SHOTS (a directory for screenshots of each step).
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { extname, join, normalize } from "node:path";

const playwright = await import(process.env.PLAYWRIGHT_MODULE);
const site = process.env.LOON_DOCS;
if (!site) throw new Error("LOON_DOCS: the built site");

const types = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript",
  ".css": "text/css",
  ".svg": "image/svg+xml",
  ".woff2": "font/woff2",
  ".txt": "text/plain",
};

export function serve() {
  return new Promise((resolve) => {
    const server = createServer(async (req, res) => {
      const path = normalize(decodeURIComponent(new URL(req.url, "http://x").pathname));
      const file = join(site, path === "/" ? "index.html" : path);
      try {
        const body = await readFile(file);
        res.writeHead(200, { "content-type": types[extname(file)] ?? "application/octet-stream" });
        res.end(body);
      } catch {
        res.writeHead(404);
        res.end("not found");
      }
    });
    server.listen(0, "127.0.0.1", () =>
      resolve({ url: `http://127.0.0.1:${server.address().port}/`, close: () => server.close() }),
    );
  });
}

export const phones = {
  phone: { viewport: { width: 390, height: 844 } },
  small: { viewport: { width: 320, height: 640 } },
};

// [engineName] from argv; a context with a page, its errors collected.
export async function open(engineName, { device = "desktop", colorScheme = "light", permissions = true } = {}) {
  const engine = playwright[engineName];
  if (!engine) throw new Error(`unknown engine ${engineName}`);
  const browser = await engine.launch();
  const options = { colorScheme, viewport: { width: 1440, height: 900 } };
  if (device !== "desktop") {
    Object.assign(options, phones[device], { hasTouch: true });
    // Firefox has no isMobile.
    if (engineName !== "firefox") options.isMobile = true;
  }
  const context = await browser.newContext(options);
  if (permissions && engineName === "chromium")
    await context.grantPermissions(["clipboard-read", "clipboard-write"]);
  const page = await context.newPage();
  const errors = [];
  page.on("pageerror", (e) => errors.push(String(e)));
  page.on("console", (m) => {
    // Firefox reports third-party images' cookies (the examples' GitHub
    // avatars) as console errors; they are not the page's.
    if (m.type() === "error" && !/Cookie “[^”]*” has been rejected/.test(m.text()))
      errors.push(m.text());
  });
  return { browser, context, page, errors };
}

// The page drawn, and its fonts loaded; with [slug], that page's article (a
// goto that only changes the hash keeps the old one for a frame or two).
export async function ready(page, slug) {
  await page.waitForSelector(slug === undefined ? "[data-page]" : `[data-page="${slug}"]`);
  await page.evaluate(() =>
    Promise.all([
      document.fonts.load('1em "Geist"'),
      document.fonts.load('1em "Geist Mono"'),
    ]).then(() => document.fonts.ready),
  );
}

// Prints and clears the errors the page logged since the last check.
export function checkErrors(errors, where) {
  for (const e of errors.splice(0)) console.log(`ERROR on ${where}: ${e}`);
}

let shot = 0;
export async function screenshot(page, name) {
  if (!process.env.SHOTS) return;
  shot += 1;
  const engine = process.argv[2];
  await page.screenshot({ path: join(process.env.SHOTS, `${engine}-${String(shot).padStart(2, "0")}-${name}.png`) });
}

// The pages the sidebar links to, in its order.
export async function pages(page) {
  return page.$$eval("[data-docs-sidebar-content] a[data-slug]", (links) =>
    links.map((a) => ({ slug: a.dataset.slug, title: a.textContent.trim(), href: a.getAttribute("href") })),
  );
}

export const text = (page, selector) =>
  page.$eval(selector, (el) => el.textContent.replace(/\s+/g, " ").trim());

// Elements wider than the viewport (sideways scrolling), by a short name.
export async function overflow(page) {
  return page.evaluate(() => {
    const width = document.documentElement.clientWidth;
    const out = [];
    if (document.documentElement.scrollWidth > width) out.push(`document ${document.documentElement.scrollWidth}>${width}`);
    return out;
  });
}

export async function waitForHash(page, hash) {
  await page.waitForFunction((h) => location.hash === h, hash);
}

export async function run(main) {
  const engine = process.argv[2];
  const server = await serve();
  try {
    await main(engine, server.url);
  } finally {
    server.close();
  }
}

// Waits for Bonsai to have drawn what the last input changed (it draws on
// animation frames).
export const settle = (page) =>
  page.evaluate(() => new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r))));
