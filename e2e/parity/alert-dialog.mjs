// Alert dialog: the Demo, as a modal that an outside click does not close
// (see overlay.mjs's modalChecks); Cancel and Continue close it.
import { both } from "./lib.mjs";
import { modalChecks } from "./overlay.mjs";

const b = await both();
await b.open("alert_dialog", "Demo", "alert-dialog-demo");
await modalChecks(b, {
  name: "demo",
  trigger: "[data-slot=alert-dialog-trigger]",
  content: "[data-slot=alert-dialog-content]",
  overlay: "[data-slot=alert-dialog-overlay]",
  dismissOutside: false,
  tabs: 3,
  closeButton: "[data-slot=alert-dialog-cancel]",
});
await b.close();
