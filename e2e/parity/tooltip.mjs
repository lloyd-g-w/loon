// Tooltip: the Demo, by hover and keyboard focus (see overlay.mjs's
// hoverChecks): delays, place and arrow, Escape, a click on the trigger.
import { both } from "./lib.mjs";
import { hoverChecks } from "./overlay.mjs";

const b = await both();
await b.open("tooltip", "Demo", "tooltip-demo");
await hoverChecks(b, {
  name: "demo",
  trigger: "[data-slot=tooltip-trigger]",
  content: "[data-slot=tooltip-content]",
  arrow: "[data-slot=tooltip-content] svg, [data-slot=tooltip-content] [class*=rotate-45]",
});
await b.close();
