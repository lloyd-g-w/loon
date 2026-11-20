// Every page in the sidebar, the guides, navigation and back/forward, the
// outline and the pager, on a desktop.
import { checkErrors, open, overflow, pages, ready, run, screenshot, settle, text, waitForHash } from "./lib.mjs";

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(url);
  await ready(page);
  console.log(`home: ${await page.title()} | ${await text(page, ".docs-hero-title")}`);
  console.log(`current: ${await text(page, ".docs-nav-link[aria-current=page]")}`);
  await screenshot(page, "home");
  checkErrors(errors, "home");

  const all = await pages(page);
  const groups = await page.$$eval(".docs-nav-group", (gs) =>
    gs.map((g) => `${g.querySelector(".docs-nav-heading").textContent.trim()}: ${[...g.querySelectorAll(".docs-nav-link")].map((l) => l.textContent.trim()).join(", ")}`),
  );
  for (const g of groups) console.log(`sidebar ${g}`);
  const guides = await page.$$eval(".docs-nav-group:first-child .docs-nav-link", (ls) =>
    ls.map((l) => l.textContent.trim()),
  );
  console.log(`guides: ${guides.join(", ")}`);

  // Each page, reached from the sidebar.
  let bad = 0;
  for (const p of all) {
    await page.click(`.docs-nav-link[data-slug="${p.slug}"]`);
    await page.waitForSelector(`.docs-article[data-page="${p.slug}"]`);
    await settle(page);
    const problems = [];
    const h1 = await page.$eval(".docs-article h1", (h) => h.textContent.trim()).catch(() => "");
    if (p.slug !== "introduction" && h1 !== p.title) problems.push(`h1 "${h1}"`);
    const current = await text(page, ".docs-nav-link[aria-current=page]");
    if (current !== p.title) problems.push(`current "${current}"`);
    const expectedTitle = p.slug === "introduction" ? "loon — components for Bonsai" : `${p.title} · loon`;
    if ((await page.title()) !== expectedTitle) problems.push(`title "${await page.title()}"`);
    const empty = await page.$$eval(".docs-preview", (ps) => ps.filter((p) => p.childElementCount === 0).length);
    if (empty) problems.push(`${empty} empty previews`);
    const toc = await page.$$eval(".docs-toc-link", (ls) => ls.length);
    const outlined = await page.$$eval(".docs-article [data-outline]", (hs) => hs.length);
    if (toc !== outlined) problems.push(`outline ${toc} of ${outlined}`);
    for (const o of await overflow(page)) problems.push(o);
    for (const e of errors.splice(0)) problems.push(`error: ${e}`);
    if (problems.length) {
      bad += 1;
      console.log(`page ${p.slug}: ${problems.join("; ")}`);
    }
  }
  console.log(`every page: ${bad === 0 ? "ok" : `${bad} with problems`} (h1, current link, title, previews, outline, no overflow or errors)`);

  // Back and forward.
  await page.goto(`${url}#/installation`);
  await ready(page, "installation");
  await page.click('.docs-nav-link[data-slug="theming"]');
  await waitForHash(page, "#/theming");
  await page.click('.docs-nav-link[data-slug="cli"]');
  await page.waitForSelector('.docs-article[data-page="cli"]');
  await page.goBack();
  await page.waitForSelector('.docs-article[data-page="theming"]');
  console.log(`back: ${await text(page, ".docs-article h1")}`);
  await page.goBack();
  await page.waitForSelector('.docs-article[data-page="installation"]');
  console.log(`back: ${await text(page, ".docs-article h1")}`);
  await page.goForward();
  await page.waitForSelector('.docs-article[data-page="theming"]');
  console.log(`forward: ${await text(page, ".docs-article h1")}`);
  const top = await page.evaluate(() => window.scrollY);
  console.log(`scrolled to the top: ${top === 0}`);
  await settle(page);

  // The outline: its links, and following one.
  const outline = await page.$$eval(".docs-toc-link", (ls) => ls.map((l) => l.textContent.trim()));
  console.log(`theming outline: ${outline.join(" | ")}`);
  await page.click('.docs-toc-link[data-target="variables"]');
  await waitForHash(page, "#/theming/variables");
  await page.waitForFunction(() => {
    const r = document.getElementById("variables").getBoundingClientRect();
    return r.top >= 0 && r.top < 200;
  });
  console.log(`outline link: heading in view, hash ${await page.evaluate(() => location.hash)}`);
  await page.waitForSelector('.docs-toc-link[data-target="variables"][data-active]');
  console.log(`outline marks: ${await text(page, ".docs-toc-link[data-active]")}`);
  await screenshot(page, "theming-variables");

  // The pager.
  await page.goto(`${url}#/installation`);
  await ready(page, "installation");
  console.log(`pager: ${await text(page, ".docs-pager")}`);
  await page.click(".docs-pager-next");
  await page.waitForSelector('.docs-article[data-page="theming"]');
  console.log(`next: ${await text(page, ".docs-article h1")}`);

  // A page that does not exist.
  await page.goto(`${url}#/no-such-component`);
  await page.waitForSelector('.docs-article[data-page=""]');
  console.log(`missing: ${await text(page, ".docs-article h1")} | ${await page.title()}`);
  await page.click(".docs-article a.loon-button");
  await page.waitForSelector('.docs-article[data-page="introduction"]');
  console.log(`back home: ${await page.evaluate(() => location.hash)}`);

  // Topnav: Components goes to the first component's page.
  await page.click(".docs-topnav-link:nth-child(2)");
  await page.waitForSelector('.docs-article:not([data-page="introduction"])');
  console.log(`components: ${await page.evaluate(() => location.hash)}`);
  console.log(`topnav active: ${await text(page, ".docs-topnav-link[data-active]")}`);

  // Opened at a page far down the sidebar, the sidebar shows its link.
  await page.setViewportSize({ width: 1280, height: 600 });
  await page.goto(`${url}#/toast`);
  await ready(page, "toast");
  await page.waitForFunction(() => document.querySelector(".docs-sidebar").scrollTop > 0);
  const shown = await page.evaluate(() => {
    const nav = document.querySelector(".docs-sidebar").getBoundingClientRect();
    const link = document.querySelector('.docs-sidebar [aria-current="page"]').getBoundingClientRect();
    return link.top >= nav.top && link.bottom <= nav.bottom;
  });
  console.log(`sidebar shows the current link: ${shown}`);
  checkErrors(errors, "navigation");
  await browser.close();
});
