// Phones (390x844, and a small one, 320x640), by touch: no page scrolls
// sideways, the sidebar is a sheet behind the menu button, the header's
// controls are 44px targets.
import { checkErrors, open, overflow, ready, run, screenshot, text, waitForHash } from "./lib.mjs";

const device = process.argv[3] ?? "phone";

const size = (page, selector) =>
  page.$eval(selector, (el) => {
    const r = el.getBoundingClientRect();
    return `${Math.round(r.width)}x${Math.round(r.height)}`;
  });

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine, { device });
  await page.goto(url);
  await ready(page);
  console.log(`${device}: sidebar hidden ${!(await page.isVisible(".docs-sidebar .docs-nav-link"))}, toc hidden ${!(await page.isVisible(".docs-toc"))}`);
  const targets = [".docs-menu-button", ".docs-search-trigger", ".docs-accent-trigger", ".docs-theme-toggle"];
  const small = [];
  for (const t of targets) {
    const [w, h] = (await size(page, t)).split("x").map(Number);
    if (w < 44 || h < 44) small.push(`${t} ${w}x${h}`);
  }
  console.log(`header targets: ${small.length ? small.join(", ") : "all at least 44px"}`);
  await screenshot(page, `${device}-home`);

  // The sheet.
  await page.tap(".docs-menu-button");
  await page.waitForSelector(".docs-sidebar[data-open]");
  await page.waitForFunction(() => {
    const r = document.querySelector(".docs-sidebar").getBoundingClientRect();
    return Math.abs(r.left) < 1;
  });
  console.log(`menu: ${await page.getAttribute(".docs-menu-button", "aria-expanded")}, ${await page.getAttribute(".docs-menu-button", "aria-label")}`);
  const links = await page.$$eval(".docs-sidebar .docs-nav-link", (ls) =>
    ls.filter((l) => l.getBoundingClientRect().height < 44).length,
  );
  console.log(`sheet links under 44px: ${links}`);
  console.log(`page scroll locked: ${await page.evaluate(() => document.body.hasAttribute("data-scroll-locked"))}`);
  await screenshot(page, `${device}-sheet`);
  await page.tap('.docs-sidebar .docs-nav-link[data-slug="theming"]');
  await waitForHash(page, "#/theming");
  await page.waitForSelector(".docs-sidebar:not([data-open])");
  console.log(`tapped a link: ${await text(page, ".docs-article h1")}, sheet closed`);
  // The scrim closes it.
  await page.tap(".docs-menu-button");
  await page.waitForSelector(".docs-nav-scrim");
  const vw = await page.evaluate(() => window.innerWidth);
  await page.touchscreen.tap(vw - 10, 400);
  await page.waitForSelector(".docs-sidebar:not([data-open])");
  console.log("scrim tap closes the sheet");

  // Search on a phone.
  await page.tap(".docs-search-trigger");
  await page.waitForSelector(".docs-search");
  const box = await page.$eval(".docs-search", (el) => {
    const r = el.getBoundingClientRect();
    return r.left >= 0 && r.right <= window.innerWidth;
  });
  console.log(`search fits: ${box}`);
  await screenshot(page, `${device}-search`);
  await page.keyboard.press("Escape");

  // No page scrolls sideways.
  const slugs = await page.$$eval(".docs-nav-link[data-slug]", (ls) => ls.map((l) => l.dataset.slug));
  const wide = [];
  for (const slug of slugs) {
    await page.goto(`${url}#/${slug}`);
    await page.waitForSelector(`.docs-article[data-page="${slug}"]`);
    for (const o of await overflow(page)) wide.push(`${slug}: ${o}`);
    for (const e of errors.splice(0)) console.log(`ERROR on ${slug}: ${e}`);
  }
  console.log(`sideways overflow: ${wide.length ? wide.join("; ") : "none"}`);
  await page.goto(`${url}#/button`);
  await ready(page);
  await screenshot(page, `${device}-button`);
  checkErrors(errors, device);
  await browser.close();
});
