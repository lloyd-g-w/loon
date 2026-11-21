// Phones (390x844, and a small one, 320x640), by touch: no page scrolls
// sideways, the sidebar is the menu behind the Menu button, the header's
// controls fit.
import { checkErrors, open, overflow, ready, run, screenshot, waitForHash } from "./lib.mjs";

const device = process.argv[3] ?? "phone";
const menu = "[data-slot=mobile-nav]";
const trigger = "[data-docs=mobile-nav-trigger]";

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine, { device });
  await page.goto(`${url}#/button`);
  await ready(page, "button");
  console.log(`${device}: sidebar hidden ${!(await page.isVisible("[data-docs-sidebar-content]"))}, toc hidden ${!(await page.isVisible("[data-slot=toc]"))}, main nav hidden ${!(await page.isVisible("[data-slot=main-nav]"))}`);
  const controls = [trigger, "[data-docs=command-menu-trigger-mobile]", "[data-docs=mode-switcher]", "[data-docs=github-link]"];
  const hidden = [];
  for (const c of controls) if (!(await page.isVisible(c))) hidden.push(c);
  console.log(`header controls: ${hidden.length ? `hidden ${hidden.join(", ")}` : "all shown"}`);
  await screenshot(page, `${device}-button`);

  // The menu.
  await page.tap(trigger);
  await page.waitForSelector(menu);
  console.log(`menu: ${await page.getAttribute(trigger, "aria-expanded")}, groups ${(await page.$$eval(`${menu} .text-muted-foreground`, (ls) => ls.map((l) => l.textContent))).slice(0, 4).join(", ")}`);
  await screenshot(page, `${device}-menu`);
  await page.locator(`${menu} a[data-slug="theming"]`).first().tap();
  await waitForHash(page, "#/theming");
  await page.waitForSelector(menu, { state: "detached" });
  console.log("tapped a link: menu closed");
  await page.tap(trigger);
  await page.waitForSelector(menu);
  await page.tap(trigger);
  await page.waitForSelector(menu, { state: "detached" });
  console.log("the button closes it");

  // Search on a phone.
  await page.tap("[data-docs=command-menu-trigger-mobile]");
  await page.waitForSelector("[data-docs=search]");
  const box = await page.$eval("[data-docs=search]", (el) => {
    const r = el.getBoundingClientRect();
    return r.left >= 0 && r.right <= window.innerWidth;
  });
  console.log(`search fits: ${box}`);
  await screenshot(page, `${device}-search`);
  await page.keyboard.press("Escape");

  // No page scrolls sideways.
  const slugs = await page.$$eval("[data-docs-sidebar-content] a[data-slug]", (ls) => [...new Set(ls.map((l) => l.dataset.slug))]);
  slugs.push("", "blocks", "chart-area", "chart-pie", "create", "typeset", "components");
  const wide = [];
  for (const slug of slugs) {
    await page.evaluate((s) => { location.hash = `#/${s}`; }, slug);
    await page.waitForSelector(`[data-page="${slug || "home"}"], [data-tool="${slug}"]`);
    for (const o of await overflow(page)) wide.push(`${slug}: ${o}`);
    for (const e of errors.splice(0)) console.log(`ERROR on ${slug}: ${e}`);
  }
  console.log(`sideways overflow: ${wide.length ? wide.join("; ") : "none"}`);
  checkErrors(errors, device);
  await browser.close();
});
