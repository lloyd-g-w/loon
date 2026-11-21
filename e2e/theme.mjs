// The theme toggle, what it changes and that a reload keeps it; and that the
// system's dark preference is the default.
import { checkErrors, open, ready, run, screenshot } from "./lib.mjs";

const theme = (page) =>
  page.evaluate(() => {
    const app = document.querySelector(".docs-app");
    const mode = (el) => (el.classList.contains("dark") ? "dark" : "light");
    return `html ${mode(document.documentElement)}, app ${mode(app)}, background ${getComputedStyle(document.body).backgroundColor !== "rgba(0, 0, 0, 0)" || getComputedStyle(document.documentElement).backgroundColor}`;
  });

await run(async (engine, url) => {
  const { browser, page, errors } = await open(engine);
  await page.goto(`${url}#/button`);
  await ready(page, "button");
  console.log(`default: ${await theme(page)}`);
  console.log(`toggle: ${await page.getAttribute(".docs-theme-toggle", "aria-label")}`);
  await page.click(".docs-theme-toggle");
  await page.waitForSelector(".docs-app.dark");
  console.log(`toggled: ${await theme(page)}`);
  console.log(`toggle: ${await page.getAttribute(".docs-theme-toggle", "aria-label")}`);
  await screenshot(page, "dark");

  await page.reload();
  await ready(page);
  console.log(`reloaded: ${await theme(page)}`);
  await page.click(".docs-theme-toggle");
  await page.waitForSelector(".docs-app:not(.dark)");
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
