// Hover card: the Demo, by hover and keyboard focus (see overlay.mjs's
// hoverChecks): delays (700ms open, 300ms close), moving onto the card,
// its place, Escape.
import { both } from "./lib.mjs";
import { hoverChecks } from "./overlay.mjs";

const b = await both();
await b.open("hover_card", "Demo", "hover-card-demo");
await hoverChecks(b, {
  name: "demo",
  trigger: "[data-slot=hover-card-trigger]",
  content: "[data-slot=hover-card-content]",
});
await b.close();
