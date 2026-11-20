// An example's Preview and Code tabs, its copy button, the highlighting,
// and the guides' code blocks.
import { checkErrors, open, ready, run, screenshot, text } from "./lib.mjs";

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(`${url}#/button`);
  await ready(page);
  const example = page.locator(".docs-example").first();
  const tabs = example.locator(".loon-tabs-trigger");
  console.log(`tabs: ${(await tabs.allTextContents()).join(" ")}; selected ${await example.locator('[aria-selected="true"]').textContent()}`);
  console.log(`preview: ${await example.locator(".docs-preview").isVisible()}, code: ${await example.locator(".docs-example-code").isVisible()}`);
  await tabs.nth(1).click();
  await example.locator(".docs-example-code").waitFor();
  const code = (await example.locator(".docs-example-code").textContent()).trim();
  console.log(`code: ${code.split("\n")[0]}`);
  const kinds = await example.locator(".docs-example-code").evaluate((pre) =>
    [...new Set([...pre.querySelectorAll("span[class^=hl-]")].map((s) => s.className))].sort().join(" "),
  );
  console.log(`highlighted: ${kinds}`);
  await screenshot(page, "code-tab");
  // Keyboard: back to Preview with an arrow.
  await tabs.nth(1).focus();
  await page.keyboard.press("ArrowLeft");
  await example.locator(".docs-preview").waitFor();
  console.log(`arrow left: ${await example.locator('[aria-selected="true"]').textContent()}, focused ${await page.evaluate(() => document.activeElement.textContent)}`);

  // Copying an example copies its source.
  await example.locator(".docs-example-card > .docs-copy").click();
  await example.locator(".docs-example-card > .docs-copy[data-copied]").waitFor();
  const copied = await page.evaluate(() => window.loonLastCopy);
  console.log(`copied the source: ${copied === code}`);
  if (engine === "chromium") {
    const clip = await page.evaluate(() => navigator.clipboard.readText());
    console.log(`clipboard: ${clip === code}`);
  }
  await page.waitForSelector(".docs-example-card > .docs-copy[data-copied]", { state: "detached", timeout: 5000 });
  console.log("copy mark: gone after a moment");

  // The page's header: its source link and loon add command.
  console.log(`header: ${await text(page, ".docs-page-links")}`);
  console.log(`source: ${await page.getAttribute(".docs-page-links a", "href")}`);

  // Guides' code blocks.
  await page.goto(`${url}#/installation`);
  await page.waitForSelector('.docs-article[data-page="installation"]');
  const blocks = await page.$$eval(".docs-codeblock", (bs) => bs.length);
  console.log(`installation: ${blocks} code blocks`);
  const dune = page.locator(".docs-codeblock", { hasText: "(executable" });
  console.log(`dune highlighted: ${await dune.locator(".hl-keyword").first().textContent()}`);
  await dune.locator(".docs-copy").click();
  console.log(`copied dune: ${(await page.evaluate(() => window.loonLastCopy)).split("\n")[0]}`);
  checkErrors(errors, "examples");
  await browser.close();
});
