// An example's preview and its View Code, copying, the highlighting, the
// installation snippet, Copy Page, the guides' code blocks, and overlays
// opened from previews (not clipped by the preview, above the header).
import { checkErrors, open, ready, run, screenshot, settle, text } from "./lib.mjs";

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(`${url}#/button`);
  await ready(page, "button");
  const example = page.locator("[data-slot=component-preview]").first();
  console.log(`preview: ${await example.locator("[data-slot=preview]").isVisible()}, code collapsed: ${await example.locator("[data-docs=view-code]").isVisible()}`);
  await example.locator("[data-docs=view-code]").click();
  await example.locator("[data-docs=view-code]").waitFor({ state: "detached" });
  const pre = example.locator("[data-slot=code] pre > :not([data-slot=copy-button])");
  const code = (await pre.textContent()).trim();
  console.log(`code: ${code.split("\n")[0]}`);
  const kinds = await pre.evaluate((el) =>
    [...new Set([...el.querySelectorAll("span[class^=hl-]")].map((s) => s.className))].sort().join(" "),
  );
  console.log(`highlighted: ${kinds}`);
  await screenshot(page, "code");

  // Copying an example copies its source; the button does not cover the code.
  const copy = example.locator("[data-slot=code] [data-slot=copy-button]");
  const covers = await page.evaluate(() => {
    const b = document.querySelector("[data-slot=component-preview] [data-slot=code] [data-slot=copy-button]").getBoundingClientRect();
    const pre = document.querySelector("[data-slot=component-preview] [data-slot=code] pre");
    const walker = document.createTreeWalker(pre, NodeFilter.SHOW_TEXT);
    const range = document.createRange();
    for (let n = walker.nextNode(); n; n = walker.nextNode()) {
      if (n.parentElement.closest("[data-slot=copy-button]") || !n.textContent.trim()) continue;
      range.selectNodeContents(n);
      for (const r of range.getClientRects())
        if (r.right > b.left && r.left < b.right && r.top < b.bottom && r.bottom > b.top) return true;
    }
    return false;
  });
  console.log(`copy button covers code: ${covers}`);
  await copy.click();
  await page.waitForSelector("[data-slot=component-preview] [data-slot=code] [data-slot=copy-button][data-copied=true]");
  const copied = await page.evaluate(() => window.loonLastCopy);
  console.log(`copied the source: ${copied.trim() === code}`);
  if (engine === "chromium") {
    const clip = await page.evaluate(() => navigator.clipboard.readText());
    console.log(`clipboard: ${clip.trim() === code}`);
  }
  await page.waitForSelector("[data-slot=component-preview] [data-slot=code] [data-slot=copy-button][data-copied=false]", { timeout: 5000 });
  console.log("copy mark: gone after a moment");

  // Installation, and Copy Page.
  console.log(`installation: ${await text(page, '[data-page="button"] code[data-language=bash]')}`);
  await page.click("[data-docs=copy-page] button:has-text('Copy Page')");
  console.log(`copy page: ${(await page.evaluate(() => window.loonLastCopy)).split("\n")[0]}`);
  await page.click("[data-docs=copy-page] [data-slot=dropdown-menu-trigger]");
  await page.waitForSelector("[data-slot=dropdown-menu-content]");
  console.log(`page links: ${(await page.$$eval("[data-slot=dropdown-menu-item]", (is) => is.map((i) => i.textContent.trim()))).join(", ")}`);
  await page.keyboard.press("Escape");
  await page.waitForSelector("[data-slot=dropdown-menu-content]", { state: "detached" });

  // Guides' code blocks: no installation snippet.
  await page.goto(`${url}#/installation`);
  await page.waitForSelector('[data-page="installation"]');
  const blocks = await page.$$eval('[data-page="installation"] figure[data-rehype-pretty-code-figure]', (bs) => bs.length);
  console.log(`installation guide: ${blocks} code blocks, loon add snippet ${await page.isVisible('h2:text-is("Installation")')}`);
  const dune = page.locator("figure[data-rehype-pretty-code-figure]", { hasText: "(executable" }).first();
  console.log(`dune highlighted: ${await dune.locator(".hl-keyword").first().textContent()}`);
  await dune.hover();
  await dune.locator("[data-slot=copy-button]").click();
  console.log(`copied dune: ${(await page.evaluate(() => window.loonLastCopy)).split("\n")[0]}`);

  // Overlays from previews: drawn whole, above the header.
  const overlays = [
    ["select", "[data-slot=select-trigger]", "[data-slot=select-content]"],
    ["dropdown_menu", "[data-slot=dropdown-menu-trigger]", "[data-slot=dropdown-menu-content]"],
    ["popover", "[data-slot=popover-trigger]", "[data-slot=popover-content]"],
    ["dialog", "[data-slot=dialog-trigger]", "[data-slot=dialog-content]"],
    ["sheet", "[data-slot=sheet-trigger]", "[data-slot=sheet-content]"],
  ];
  for (const [slug, trigger, content] of overlays) {
    await page.goto(`${url}#/${slug}`);
    await ready(page, slug);
    // The trigger just under the header, so a menu below it overlaps nothing
    // but one above it would be under the header if the header won.
    await page.locator(`[data-page="${slug}"] ${trigger}`).first().evaluate((el) => {
      el.scrollIntoView({ block: "start" });
      window.scrollBy(0, -70);
    });
    await settle(page);
    await page.locator(`[data-page="${slug}"] ${trigger}`).first().click();
    await page.waitForSelector(content);
    // Until its enter animation (a sheet slides in for 500ms) is over.
    await page.waitForTimeout(50);
    await page.evaluate((sel) =>
      Promise.all(document.querySelector(sel).getAnimations({ subtree: true }).map((a) => a.finished)),
      content,
    );
    const r = await page.evaluate((sel) => {
      const el = document.querySelector(sel);
      const b = el.getBoundingClientRect();
      const x = b.left + b.width / 2, y = Math.max(b.top + 4, 1);
      const hit = document.elementFromPoint(x, y);
      const header = document.querySelector("header").getBoundingClientRect();
      return {
        top: el.matches(":popover-open, :modal") || !!el.closest(":popover-open, dialog[open]"),
        onTop: el.contains(hit),
        overHeader: b.top < header.bottom,
      };
    }, content);
    console.log(`${slug}: top layer ${r.top}, hit-tested on top ${r.onTop}${r.overHeader ? ", over the header" : ""}`);
    await page.keyboard.press("Escape");
    await page.waitForSelector(content, { state: "detached" });
  }
  checkErrors(errors, "examples");
  await browser.close();
});
