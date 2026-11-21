// Calendar: the Demo (single, dropdown caption) and Range Calendar (two
// months) examples against shadcn's calendar-demo and a range page:
// keyboard grid navigation, month buttons, selection, focus and ARIA.
import { both, compare, each, inRoot, shotRoot as shot, wait } from "./lib.mjs";

const b = await both();
const state = () => {
  const root = document.querySelector("[data-parity-root] [data-slot=calendar]");
  const a = document.activeElement;
  const sel = [...root.querySelectorAll("[data-selected-single=true], [data-range-start=true], [data-range-end=true]")]
    .map((d) => d.dataset.day);
  const middle = root.querySelectorAll("[data-range-middle=true]").length;
  return {
    focus: a?.dataset?.day ?? a?.getAttribute("aria-label") ?? a?.tagName,
    focusLabel: a?.getAttribute("aria-label"),
    tabbable: [...root.querySelectorAll("button[tabindex='0']")].map((d) => d.dataset.day),
    months: [...root.querySelectorAll(".rdp-month_caption")].map((c) =>
      c.querySelector("select") ? [...c.querySelectorAll(".rdp-caption_label")].map((l) => l.textContent.trim()).join(" ") : c.textContent.trim()),
    selects: [...root.querySelectorAll("select")].map((s) => s.value),
    selected: sel,
    middle,
    prevDisabled: root.querySelector(".rdp-button_previous")?.getAttribute("aria-disabled") ?? null,
    nextDisabled: root.querySelector(".rdp-button_next")?.getAttribute("aria-disabled") ?? null,
  };
};
const press = async (key, label = key) => {
  await each(b, (p) => p.keyboard.press(key));
  await wait(b, 150);
  await compare(b, label, state);
};

await b.open("calendar", "Demo", "calendar-demo");
await compare(b, "initial", state);
// Focus the tabbable day (today, selected), then move round the grid.
await each(b, (p) => inRoot(p, "button[tabindex='0'][data-day]").focus());
await compare(b, "focused", state);
for (const k of ["ArrowRight", "ArrowDown", "ArrowLeft", "ArrowUp", "Home", "End", "PageDown", "PageUp", "Shift+PageDown", "Shift+PageUp"])
  await press(k);
await press("Enter", "Enter selects");
await press("ArrowRight");
await press("Space", "Space selects");
await press("Space", "Space again (deselect?)");
await shot(b, "calendar-keys");
// Month buttons.
await each(b, (p) => inRoot(p, ".rdp-button_next").click());
await wait(b, 150);
await compare(b, "next month", state);
await each(b, (p) => inRoot(p, ".rdp-button_previous").click());
await each(b, (p) => inRoot(p, ".rdp-button_previous").click());
await wait(b, 150);
await compare(b, "previous x2", state);
// Tab order from the previous button.
await each(b, (p) => inRoot(p, ".rdp-button_previous").focus());
for (let i = 0; i < 4; i++) await press("Tab", `Tab ${i + 1}`);
// The month dropdown.
await each(b, (p) => inRoot(p, "select").selectOption({ index: 0 }));
await wait(b, 150);
await compare(b, "month select Jan", state);
// The month select from the keyboard: focus stays on it.
await each(b, (p) => inRoot(p, "select").focus());
await press("ArrowDown", "month select ArrowDown");
// Click a day: selects; clicking it again deselects (single, not required).
await each(b, (p) => inRoot(p, "button[data-day]:not(.rdp-outside button)").first().click());
await wait(b, 150);
await compare(b, "click a day", state);
await each(b, (p) => inRoot(p, "button[data-day]:not(.rdp-outside button)").first().click());
await wait(b, 150);
await compare(b, "click it again", state);
await shot(b, "calendar-click");

// Range.
await b.open("calendar", "Range Calendar", "parity-calendar-range");
await compare(b, "range initial", state);
await shot(b, "calendar-range");
await each(b, (p) => p.locator("[data-parity-root] button[data-day]").nth(20).click());
await wait(b, 150);
await compare(b, "range click 1", state);
await each(b, (p) => p.locator("[data-parity-root] button[data-day]").nth(25).click());
await wait(b, 150);
await compare(b, "range click 2", state);
await each(b, (p) => p.locator("[data-parity-root] button[data-day]").nth(5).click());
await wait(b, 150);
await compare(b, "range click before start", state);
await shot(b, "calendar-range-picked");
await each(b, (p) => inRoot(p, "button[tabindex='0'][data-day]").focus());
await press("ArrowRight", "range ArrowRight");
await press("PageDown", "range PageDown");
await press("PageDown", "range PageDown 2");
await each(b, (p) => inRoot(p, ".rdp-button_next").click());
await wait(b, 150);
await compare(b, "range next (to the future)", state);
await b.close();
