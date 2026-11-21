// Sheet: the Demo and the Side example's four sides, as modals (see
// overlay.mjs's modalChecks): where each side's panel sits, focus, Tab
// cycling, Escape, the X and outside clicks, the slide-out animation.
import { both } from "./lib.mjs";
import { modalChecks } from "./overlay.mjs";

const b = await both();
const sel = {
  content: "[data-slot=sheet-content]",
  overlay: "[data-slot=sheet-overlay]",
  closeButton: "[data-slot=sheet-content] > button.absolute",
};
await b.open("sheet", "Demo", "sheet-demo");
await modalChecks(b, { ...sel, name: "demo", trigger: "[data-slot=sheet-trigger]", tabs: 6 });
await b.open("sheet", "Side", "sheet-side");
for (const [i, side] of ["top", "right", "bottom", "left"].entries())
  await modalChecks(b, { ...sel, name: side, trigger: `[data-slot=sheet-trigger]:nth-child(${i + 1} of [data-slot=sheet-trigger])`, tabs: 2 });
await b.close();
