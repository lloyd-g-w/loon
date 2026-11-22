// Dialog: the Demo and Custom close button examples, as modals (see
// overlay.mjs's modalChecks): open, focus, Tab cycling, Escape, the X and
// outside clicks, the scroll lock, the exit animation.
import { both } from "./lib.mjs";
import { modalChecks } from "./overlay.mjs";

const b = await both();
const sel = {
  trigger: "[data-slot=dialog-trigger]",
  content: "[data-slot=dialog-content]",
  overlay: "[data-slot=dialog-overlay]",
};
await b.open("dialog", "Demo", "dialog-demo");
await modalChecks(b, { ...sel, name: "demo", closeButton: "[data-slot=dialog-content] > [data-slot=dialog-close]" });
await b.open("dialog", "Custom close button", "dialog-close-button");
await modalChecks(b, { ...sel, name: "close-button", tabs: 4 });
await b.close();
