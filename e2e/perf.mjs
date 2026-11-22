// node e2e/perf.mjs [--profile OUT.cpuprofile] [--only NAME]: times common
// interactions on the built docs site (LOON_DOCS, default the dune build)
// in Chromium: for each, the main thread's CPU time (all tasks; of them
// script, style recalculation, layout), the median of RUNS (default 5);
// VERBOSE=1 prints every run's. "load" is the first page's wall time,
// cold. Needs PLAYWRIGHT_MODULE and PLAYWRIGHT_BROWSERS_PATH (see ./check).
process.env.LOON_DOCS ??= new URL("../_build/default/docs/bin/site", import.meta.url).pathname;
const { open, ready, serve } = await import("./lib.mjs");
const { writeFile } = await import("node:fs/promises");

const args = process.argv.slice(2);
const profileOut = args.includes("--profile") ? args[args.indexOf("--profile") + 1] : null;
const only = args.includes("--only") ? args[args.indexOf("--only") + 1] : null;
const runs = Number(process.env.RUNS ?? 5);

const server = await serve();
const { browser, page, context, errors } = await open("chromium");
const cdp = await context.newCDPSession(page);

// The main thread's CPU time (Chrome's Performance metrics: tasks, of
// which script and style recalculation) from just before [action] until two
// animation frames have run after it (Bonsai draws on animation frames).
// CPU time, unlike wall time, holds up when the machine is busy.
await cdp.send("Performance.enable", { timeDomain: "threadTicks" });
const metrics = async () =>
  Object.fromEntries((await cdp.send("Performance.getMetrics")).metrics.map((m) => [m.name, m.value]));
async function timed(action) {
  const a = await metrics();
  await action();
  await settle();
  await settle();
  const b = await metrics();
  const d = (k) => (b[k] - a[k]) * 1000;
  return { task: d("TaskDuration"), script: d("ScriptDuration"), style: d("RecalcStyleDuration"), layout: d("LayoutDuration") };
}

const settle = () =>
  page.evaluate(() => new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(() => setTimeout(r, 30)))));

const median = (xs) => {
  const s = [...xs].sort((a, b) => a - b);
  return s[Math.floor(s.length / 2)];
};

async function goto(hash) {
  await page.goto(`${server.url}${hash}`);
  await ready(page, hash.slice(2));
  await settle();
}

const results = [];
async function measure(name, setup, action, undo) {
  if (only && !name.includes(only)) return;
  await setup();
  const ts = [];
  for (let i = 0; i < runs; i++) {
    ts.push(await timed(action));
    await settle();
    if (undo) {
      await undo();
      await settle();
    }
  }
  if (process.env.VERBOSE) console.log(ts.map((t) => `${t.task.toFixed(0)}/${t.style.toFixed(0)}`).join(" "));
  const m = (k) => median(ts.map((t) => t[k])).toFixed(1).padStart(7);
  const r = { name, task: m("task"), script: m("script"), style: m("style"), layout: m("layout") };
  console.log(`${name.padEnd(40)} task ${r.task}  script ${r.script}  style ${r.style}  layout ${r.layout} ms`);
  results.push(r);
}

if (profileOut) {
  await cdp.send("Profiler.enable");
  await cdp.send("Profiler.setSamplingInterval", { interval: 200 });
}

const t0 = Date.now();
await goto("#/button");
console.log(`load #/button: ${Date.now() - t0} ms`);
if (profileOut) await cdp.send("Profiler.start");

const click = (sel) => () => page.click(sel);
const esc = () => page.keyboard.press("Escape");
const first = (sel) => `${sel} >> nth=0`;

await measure(
  "dropdown-menu open",
  () => goto("#/dropdown_menu"),
  click(first('[data-slot="dropdown-menu-trigger"]')),
  esc,
);
await measure("select open", () => goto("#/select"), click(first('[data-slot="select-trigger"]')), esc);
await measure("popover open", () => goto("#/popover"), click(first('[data-slot="popover-trigger"]')), esc);
await measure("dialog open", () => goto("#/dialog"), click(first('[data-slot="dialog-trigger"]')), esc);
await measure(
  "tooltip hover",
  () => goto("#/tooltip"),
  async () => {
    await page.hover(first('[data-slot="tooltip-trigger"]'));
    await page.waitForSelector('[data-slot="tooltip-content"]');
  },
  () => page.mouse.move(0, 0),
);
await measure(
  "input type a char",
  async () => {
    await goto("#/input");
    await page.focus(first('[data-slot="input"]'));
  },
  () => page.keyboard.type("a"),
);
await measure("switch toggle", () => goto("#/switch"), click(first('[data-slot="switch"]')));
await measure(
  "create: Style picker open",
  () => goto("#/create"),
  click('[data-picker="style"] >> nth=0'),
  esc,
);
for (const [from, to] of [["button", "dropdown_menu"], ["button", "calendar"]])
  await measure(
    `page switch (${from} -> ${to})`,
    () => goto(`#/${from}`),
    async () => {
      await page.click(`[data-docs-sidebar-content] a[data-slug="${to}"] >> nth=0`);
      await page.waitForSelector(`[data-page="${to}"]`);
    },
    async () => {
      await page.click(`[data-docs-sidebar-content] a[data-slug="${from}"] >> nth=0`);
      await page.waitForSelector(`[data-page="${from}"]`);
    },
  );

if (profileOut) {
  const { profile } = await cdp.send("Profiler.stop");
  await writeFile(profileOut, JSON.stringify(profile));
  console.log(`profile written to ${profileOut}`);
}
for (const e of errors) console.log("error:", e);
await browser.close();
server.close();
