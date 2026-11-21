// The search (shadcn's CommandMenu on the ported Command in a Dialog):
// opening it (button, Ctrl+K, /), filtering, the keyboard and going to a
// result.
import { checkErrors, open, ready, run, screenshot, settle, waitForHash } from "./lib.mjs";

const dialog = "[data-docs=search]";
const input = `${dialog} [cmdk-input]`;
const results = async (page) => {
  await settle(page);
  return page.$$eval(`${dialog} [cmdk-item]`, (rs) =>
    rs.map((r) => `${r.getAttribute("data-selected") === "true" ? ">" : ""}${r.childNodes[1]?.textContent ?? r.textContent}`),
  );
};
const focused = (page) => page.waitForFunction((s) => document.activeElement === document.querySelector(s), input);

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(`${url}#/installation`);
  await ready(page, "installation");
  await page.click("[data-docs=command-menu-trigger]");
  await page.waitForSelector(dialog);
  await focused(page);
  const empty = await results(page);
  console.log(`opened by the button, input focused; first results: ${empty.slice(0, 4).join(", ")}`);
  const groups = await page.$$eval(`${dialog} [cmdk-group-heading]`, (hs) => hs.map((h) => h.textContent));
  console.log(`groups: ${groups.join(", ")}`);
  await page.keyboard.type("intal");
  console.log(`"intal": ${(await results(page)).slice(0, 3).join(", ")}`);
  await screenshot(page, "search");
  await page.keyboard.press("Escape");
  await page.waitForSelector(dialog, { state: "detached" });
  console.log("Escape closes it");

  await page.keyboard.press("Control+k");
  await page.waitForSelector(dialog);
  await focused(page);
  console.log(`Ctrl+K opens it, empty: ${(await page.inputValue(input)) === ""}`);
  await page.keyboard.type("themng");
  console.log(`"themng": ${(await results(page)).slice(0, 3).join(", ")}`);
  await page.keyboard.press("Enter");
  await waitForHash(page, "#/theming");
  await page.waitForSelector(dialog, { state: "detached" });
  console.log(`Enter: ${await page.evaluate(() => location.hash)}, closed`);

  await settle(page);
  await page.keyboard.press("/");
  await page.waitForSelector(dialog);
  await focused(page);
  await page.keyboard.type("dialog");
  console.log(`"dialog": ${(await results(page)).slice(0, 3).join(", ")}`);
  await page.keyboard.press("ArrowDown");
  console.log(`ArrowDown: ${(await results(page)).find((r) => r.startsWith(">"))}`);
  await page.fill(input, "qqqzz");
  await settle(page);
  console.log(`no match: ${await page.textContent(`${dialog} [cmdk-empty]`)}`);
  await page.fill(input, "cli");
  await settle(page);
  await page.click(`${dialog} [cmdk-item] >> nth=0`);
  await waitForHash(page, "#/cli");
  console.log(`click: ${await page.evaluate(() => location.hash)}`);

  // A click outside closes it.
  await page.waitForSelector('[data-page="cli"]');
  await settle(page);
  await page.keyboard.press("Control+k");
  await page.waitForSelector(dialog);
  await focused(page);
  await page.mouse.click(10, 500);
  await page.waitForSelector(dialog, { state: "detached" });
  console.log("outside click closes it");
  checkErrors(errors, "search");
  await browser.close();
});
