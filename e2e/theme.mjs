// The theme toggle and accent picker, what they change and that a reload
// keeps them; and that the system's dark preference is the default.
import { checkErrors, open, ready, run, screenshot } from "./lib.mjs";

const theme = (page) =>
  page.evaluate(() => {
    const app = document.querySelector(".docs-app");
    const mode = (el) => (el.classList.contains("loon-dark") ? "dark" : "light");
    return `html ${mode(document.documentElement)}/${document.documentElement.dataset.loonAccent}, app ${mode(app)}/${app.dataset.loonAccent}, background ${getComputedStyle(document.body).backgroundColor !== "rgba(0, 0, 0, 0)" || getComputedStyle(document.documentElement).backgroundColor}`;
  });

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(`${url}#/button`);
  await ready(page);
  console.log(`default: ${await theme(page)}`);
  console.log(`toggle: ${await page.getAttribute(".docs-theme-toggle", "aria-label")}`);
  await page.click(".docs-theme-toggle");
  await page.waitForSelector(".docs-app.loon-dark");
  console.log(`toggled: ${await theme(page)}`);
  console.log(`toggle: ${await page.getAttribute(".docs-theme-toggle", "aria-label")}`);
  await screenshot(page, "dark");

  // The accent picker.
  await page.click(".docs-accent-trigger");
  await page.waitForSelector(".docs-accent-menu");
  const options = await page.$$eval(".docs-accent-option", (os) =>
    os.map((o) => `${o.textContent.trim()}${o.getAttribute("aria-checked") === "true" ? "*" : ""}`),
  );
  console.log(`accents: ${options.join(" ")}`);
  await screenshot(page, "accent-menu");
  await page.click('.docs-accent-option[data-accent="iris"]');
  await page.waitForSelector(".docs-accent-menu", { state: "detached" });
  console.log(`iris: ${await theme(page)}`);
  // Escape closes it; so does a click away.
  await page.click(".docs-accent-trigger");
  await page.waitForSelector(".docs-accent-menu");
  await page.waitForFunction(() => document.activeElement?.dataset.accent === "iris");
  console.log(`focus on opening: ${await page.evaluate(() => document.activeElement.textContent)}`);
  await page.keyboard.press("ArrowDown");
  console.log(`arrow down: ${await page.evaluate(() => document.activeElement.textContent)}`);
  await page.keyboard.press("Escape");
  await page.waitForSelector(".docs-accent-menu", { state: "detached" });
  await page.waitForFunction(() => document.activeElement?.classList.contains("docs-accent-trigger"));
  await page.click(".docs-accent-trigger");
  await page.waitForSelector(".docs-accent-menu");
  await page.mouse.click(700, 600);
  await page.waitForSelector(".docs-accent-menu", { state: "detached" });
  console.log("accent menu: closes on Escape and outside clicks");

  await page.reload();
  await ready(page);
  console.log(`reloaded: ${await theme(page)}`);
  await page.click(".docs-theme-toggle");
  await page.waitForSelector(".docs-app.loon-light");
  await page.reload();
  await ready(page);
  console.log(`light again, reloaded: ${await theme(page)}`);
  checkErrors(errors, "theme");
  await browser.close();

  // A system in dark mode, nothing stored.
  const dark = await open(engine, { colorScheme: "dark" });
  await dark.page.goto(url);
  await ready(dark.page);
  console.log(`system dark: ${await theme(dark.page)}`);
  checkErrors(dark.errors, "system dark");
  await dark.browser.close();
});
