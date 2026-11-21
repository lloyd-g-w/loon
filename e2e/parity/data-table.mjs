// Data table: loon's Demo against shadcn's data-table-demo: sorting by
// email, filtering, selecting rows (one, all), the Columns menu (hiding a
// column, by mouse and keyboard), a row's actions menu, and pagination.
import { both, compare, each, inRoot, shot, wait } from "./lib.mjs";

const b = await both();
const state = () => {
  const root = document.querySelector("[data-parity-root]");
  const rows = [...root.querySelectorAll("tbody [data-slot=table-row]")];
  const a = document.activeElement;
  const menu = document.querySelector("[data-slot=dropdown-menu-content]");
  return {
    headers: [...root.querySelectorAll("thead th")].map((th) => th.textContent.trim()),
    rows: rows.map((r) =>
      [r.dataset.state ?? "-", ...[...r.querySelectorAll("td")].slice(1, 4).map((td) => td.textContent.trim())].join("|"),
    ),
    selectAll: root.querySelector("thead [role=checkbox]")?.getAttribute("aria-checked"),
    footer: [...root.querySelectorAll("div")].find((d) => /row\(s\) selected/.test(d.textContent) && d.children.length === 0)?.textContent.trim(),
    pager: [...root.querySelectorAll("button")].filter((x) => /Previous|Next/.test(x.textContent)).map((x) => `${x.textContent.trim()}:${x.disabled}`),
    menu: menu && {
      state: menu.dataset.state,
      items: [...menu.querySelectorAll("[role^=menuitem]")].map((i) => `${i.textContent.trim()}${i.getAttribute("aria-checked") ? ":" + i.getAttribute("aria-checked") : ""}${i.hasAttribute("data-highlighted") ? "*" : ""}`),
    },
    focus: a?.getAttribute("aria-label") ?? a?.textContent?.trim().slice(0, 20) ?? a?.tagName,
  };
};

await b.open("data_table", "Demo", "data-table-demo");
await compare(b, "initial", state);
const button = (p, text) => p.locator("[data-parity-root] button", { hasText: text }).first();
await each(b, (p) => button(p, "Email").click());
await wait(b, 100);
await compare(b, "sort by email", state);
await each(b, (p) => button(p, "Email").click());
await wait(b, 100);
await compare(b, "sort by email again", state);
await each(b, (p) => inRoot(p, "input").fill("ken"));
await wait(b, 100);
await compare(b, "filter 'ken'", state);
await each(b, (p) => inRoot(p, "input").fill(""));
await wait(b, 100);
await each(b, (p) => p.locator("[data-parity-root] tbody [role=checkbox]").nth(1).click());
await wait(b, 100);
await compare(b, "select row 2", state);
await each(b, (p) => inRoot(p, "thead [role=checkbox]").click());
await wait(b, 100);
await compare(b, "select all", state);
await each(b, (p) => inRoot(p, "thead [role=checkbox]").click());
await wait(b, 100);
await compare(b, "select none", state);
// Columns menu.
await each(b, (p) => button(p, "Columns").click());
await wait(b, 300);
await compare(b, "Columns opened", state);
await shot(b, "data-table-columns");
await each(b, (p) => p.locator("[data-slot=dropdown-menu-checkbox-item]", { hasText: "amount" }).click());
await wait(b, 300);
await compare(b, "amount unchecked", state);
await each(b, (p) => button(p, "Columns").press("Enter"));
await wait(b, 300);
await compare(b, "Columns by Enter", state);
await each(b, (p) => p.keyboard.press("ArrowDown"));
await compare(b, "Columns: ArrowDown", state);
await each(b, (p) => p.keyboard.press("Space"));
await wait(b, 300);
await compare(b, "Columns: Space", state);
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 300);
await compare(b, "Columns: Escape", state);
// A row's actions.
await each(b, (p) => p.locator("[data-parity-root] tbody [data-slot=dropdown-menu-trigger]").first().click());
await wait(b, 300);
await compare(b, "row actions opened", state);
await shot(b, "data-table-actions");
await each(b, (p) => p.keyboard.press("Escape"));
await wait(b, 300);
// Pagination (5 rows, 10 per page in shadcn's demo).
await each(b, (p) => button(p, "Next").click({ timeout: 2000 }).catch(() => {}));
await wait(b, 100);
await compare(b, "Next", state);
await shot(b, "data-table-end");
await b.close();
