// The search: opening it (button, Ctrl+K, /), filtering, the keyboard and
// going to a result.
import { checkErrors, open, ready, run, screenshot, settle, waitForHash } from "./lib.mjs";

const results = async (page) => {
  await settle(page);
  return page.$$eval(".docs-search-result", (rs) =>
    rs.map((r) => `${r.hasAttribute("data-selected") ? ">" : ""}${r.querySelector(".docs-search-title").textContent}`),
  );
};

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(`${url}#/installation`);
  await ready(page);
  await page.click(".docs-search-trigger");
  await page.waitForSelector(".docs-search");
  await page.waitForFunction(() => document.activeElement?.id === "docs-search-input");
  const empty = await results(page);
  console.log(`opened by the button, input focused; first results: ${empty.slice(0, 4).join(", ")}`);
  await page.keyboard.type("intal");
  console.log(`"intal": ${(await results(page)).slice(0, 3).join(", ")}`);
  await screenshot(page, "search");
  await page.keyboard.press("Escape");
  await page.waitForSelector(".docs-search", { state: "detached" });
  console.log("Escape closes it");

  await page.keyboard.press("Control+k");
  await page.waitForSelector(".docs-search");
  await page.waitForFunction(() => document.activeElement?.id === "docs-search-input");
  console.log(`Ctrl+K opens it, empty: ${(await page.inputValue("#docs-search-input")) === ""}`);
  await page.keyboard.type("themng");
  console.log(`"themng": ${(await results(page)).slice(0, 3).join(", ")}`);
  await page.keyboard.press("Enter");
  await waitForHash(page, "#/theming");
  await page.waitForSelector(".docs-search", { state: "detached" });
  console.log(`Enter: ${await page.evaluate(() => location.hash)}, closed`);

  await settle(page);
  await page.keyboard.press("/");
  await page.waitForSelector(".docs-search");
  await page.keyboard.type("cli");
  await settle(page);
  await page.keyboard.press("ArrowDown");
  await page.keyboard.press("ArrowUp");
  await page.keyboard.press("ArrowUp");
  const wrapped = await results(page);
  console.log(`"/" opens it; arrows wrap: ${wrapped.findIndex((r) => r.startsWith(">")) === wrapped.length - 1}`);
  await page.fill("#docs-search-input", "qqqzz");
  console.log(`no match: ${await page.textContent(".docs-search-empty")}`);
  await page.fill("#docs-search-input", "cli");
  await page.click(".docs-search-result >> nth=0");
  await waitForHash(page, "#/cli");
  console.log(`click: ${await page.evaluate(() => location.hash)}`);

  // A click on the scrim closes it (once the page it went to is drawn: a
  // change of page closes the search).
  await page.waitForSelector('.docs-article[data-page="cli"]');
  await settle(page);
  await page.keyboard.press("Control+k");
  await page.waitForSelector(".docs-search");
  await page.waitForFunction(() => document.activeElement?.id === "docs-search-input");
  await page.click(".docs-scrim", { position: { x: 10, y: 10 }, force: true });
  await page.waitForSelector(".docs-search", { state: "detached" });
  console.log("scrim click closes it");
  checkErrors(errors, "search");
  await browser.close();
});
