// Every page in the sidebar, the sections outside the docs (Blocks, Charts,
// Create, Typeset), navigation and back/forward, the outline and the pager,
// on a desktop.
import { checkErrors, open, overflow, pages, ready, run, screenshot, settle, sidebarLink, text, waitForHash } from "./lib.mjs";

const h1 = (page, slug) => page.$eval(`[data-page="${slug}"] h1`, (h) => h.textContent.trim()).catch(() => "");

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(url);
  await ready(page, "home");
  console.log(`home: ${await page.title()} | ${(await h1(page, "home")).replace(/\s+/g, " ")}`);
  const nav = await page.$$eval("[data-slot=main-nav] a", (as) => as.map((a) => a.textContent.trim()));
  console.log(`header: ${nav.join(", ")}`);
  await screenshot(page, "home");
  checkErrors(errors, "home");

  await page.goto(`${url}#/introduction`);
  await ready(page, "introduction");
  console.log(`current: ${await text(page, "[data-docs-sidebar-content] a[data-active=true]")}`);
  const all = await pages(page);
  const groups = await page.$$eval("[data-docs-sidebar-content] [data-slot=sidebar-group]", (gs) =>
    gs.map((g) => `${g.querySelector("[data-slot=sidebar-group-label]").textContent.trim()}: ${[...g.querySelectorAll("a[data-slug]")].map((l) => l.textContent.trim()).join(", ")}`),
  );
  for (const g of groups) console.log(`sidebar ${g}`);

  // Each page, reached from the sidebar.
  let bad = 0;
  const check = async (slug, title) => {
    const problems = [];
    const heading = await h1(page, slug);
    if (title && heading !== title) problems.push(`h1 "${heading}"`);
    const empty = await page.$$eval("[data-slot=preview] > div", (ps) => ps.filter((p) => p.childElementCount === 0).length);
    if (empty) problems.push(`${empty} empty previews`);
    const toc = await page.$$eval("[data-slot=toc-link]", (ls) => ls.length);
    const outlined = await page.$$eval("[data-page] [data-outline]", (hs) => hs.length);
    if (toc !== 0 && toc !== outlined) problems.push(`outline ${toc} of ${outlined}`);
    for (const o of await overflow(page)) problems.push(o);
    for (const e of errors.splice(0)) problems.push(`error: ${e}`);
    if (problems.length) {
      bad += 1;
      console.log(`page ${slug}: ${problems.join("; ")}`);
    }
  };
  for (const p of all) {
    await page.click(sidebarLink(p.slug));
    await page.waitForSelector(`[data-page="${p.slug}"]`);
    await settle(page);
    const current = await text(page, "[data-docs-sidebar-content] a[data-active=true]");
    if (current !== p.title) console.log(`page ${p.slug}: current "${current}"`);
    if ((await page.title()) !== `${p.title} - loon`) console.log(`page ${p.slug}: title "${await page.title()}"`);
    await check(p.slug, p.title);
  }
  console.log(`every page: ${bad === 0 ? "ok" : `${bad} with problems`} (h1, current link, title, previews, outline, no overflow or errors)`);

  // The sections outside the docs, from the header; the charts' kinds.
  for (const label of ["Blocks", "Charts", "Create", "Typeset"]) {
    await page.click(`[data-slot=main-nav] a:text-is("${label}")`);
    await page.waitForFunction((l) => document.querySelector("[data-slot=main-nav] a[data-active=true]")?.textContent.trim() === l, label);
    const slug = await page.$eval("[data-page]", (el) => el.dataset.page);
    console.log(`${label}: #/${slug} | ${await h1(page, slug)} | ${await page.title()}`);
    await check(slug);
  }
  await page.goto(`${url}#/chart-area`);
  await ready(page, "chart-area");
  const kinds = await page.$$eval("#charts a[data-slug]", (as) => as.map((a) => a.dataset.slug));
  for (const slug of kinds) {
    await page.click(`#charts a[data-slug="${slug}"]`);
    await page.waitForSelector(`[data-page="${slug}"]`);
    await settle(page);
    await check(slug);
  }
  console.log(`charts: ${kinds.length} kinds, ${await page.$$eval("[data-slot=chart-display]", (d) => d.length)} charts on the last; installation snippet ${await page.isVisible("text=loon add")}`);

  // Back and forward.
  await page.goto(`${url}#/installation`);
  await ready(page, "installation");
  await page.click(sidebarLink("theming"));
  await waitForHash(page, "#/theming");
  await page.click(sidebarLink("cli"));
  await page.waitForSelector('[data-page="cli"]');
  await page.goBack();
  await page.waitForSelector('[data-page="theming"]');
  console.log(`back: ${await h1(page, "theming")}`);
  await page.goBack();
  await page.waitForSelector('[data-page="installation"]');
  console.log(`back: ${await h1(page, "installation")}`);
  await page.goForward();
  await page.waitForSelector('[data-page="theming"]');
  console.log(`forward: ${await h1(page, "theming")}`);
  console.log(`scrolled to the top: ${(await page.evaluate(() => window.scrollY)) === 0}`);
  await settle(page);

  // The outline: its links, and following one.
  const outline = await page.$$eval("[data-slot=toc-link]", (ls) => ls.map((l) => l.textContent.trim()));
  console.log(`theming outline: ${outline.join(" | ")}`);
  await page.click('[data-slot=toc-link][data-target="variables"]');
  await waitForHash(page, "#/theming/variables");
  await page.waitForFunction(() => {
    const r = document.getElementById("variables").getBoundingClientRect();
    return r.top >= 0 && r.top < 200;
  });
  console.log(`outline link: heading in view, hash ${await page.evaluate(() => location.hash)}`);
  await page.waitForSelector('[data-slot=toc-link][data-target="variables"][data-active=true]');
  console.log(`outline marks: ${await text(page, "[data-slot=toc-link][data-active=true]")}`);
  await screenshot(page, "theming-variables");

  // The pager.
  await page.goto(`${url}#/installation`);
  await ready(page, "installation");
  console.log(`pager: ${await text(page, "[data-slot=docs-pager]")}`);
  await page.click("[data-pager=next]");
  await page.waitForSelector('[data-page="theming"]');
  console.log(`next: ${await h1(page, "theming")}`);
  await page.click("[data-pager-icon=previous]");
  await page.waitForSelector('[data-page="installation"]');
  console.log(`previous: ${await h1(page, "installation")}`);

  // A page that does not exist.
  await page.goto(`${url}#/no-such-component`);
  await page.waitForSelector('[data-page=""]');
  console.log(`missing: ${await h1(page, "")} | ${await page.title()}`);
  await page.click('[data-page=""] a[data-slot=button]');
  await page.waitForSelector('[data-page="home"]');
  console.log(`back home: ${await page.evaluate(() => location.hash)}`);

  // Header: Components goes to the index of the components.
  await page.click('[data-slot=main-nav] a:text-is("Components")');
  await page.waitForSelector('[data-page="components"]');
  console.log(`components: ${await page.evaluate(() => location.hash)}, ${await page.$$eval('[data-page="components"] .typeset a', (as) => as.length)} links`);
  console.log(`header active: ${await text(page, "[data-slot=main-nav] a[data-active=true]")}`);

  // Opened at a page far down the sidebar, the sidebar shows its link.
  await page.setViewportSize({ width: 1280, height: 600 });
  await page.goto(`${url}#/sonner`);
  await ready(page, "sonner");
  await page.waitForFunction(() => document.querySelector("[data-docs-sidebar-content]").scrollTop > 0);
  const shown = await page.evaluate(() => {
    const nav = document.querySelector("[data-docs-sidebar-content]").getBoundingClientRect();
    const link = document.querySelector("[data-docs-sidebar-content] a[data-active=true]").getBoundingClientRect();
    return link.top >= nav.top && link.bottom <= nav.bottom;
  });
  console.log(`sidebar shows the current link: ${shown}`);
  checkErrors(errors, "navigation");
  await browser.close();
});
