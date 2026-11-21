// Toggle group: the demo (multiple, outline), Single, Disabled and Spacing
// examples: clicks, roving focus (arrows, loop, Home/End), Space/Enter,
// attributes, layout and look.
import { both, compare, each, focused, inRoot, shotRoot as shot, slots, wait } from "./lib.mjs";

const SEL = "[data-slot=toggle-group], [data-slot=toggle-group-item]";
const examples = [
  ["Demo", "toggle-group-demo"],
  ["Single", "toggle-group-single"],
  ["Disabled", "toggle-group-disabled"],
  ["Spacing", "toggle-group-spacing"],
];
const b = await both();
for (const [title, name] of examples) {
  console.log(`-- ${title}`);
  await b.open("toggle_group", title, name);
  await compare(b, "initial", slots, SEL);
  await shot(b, `${name}-initial`);
  if (title === "Disabled") {
    await each(b, (p) => inRoot(p, "[data-slot=toggle-group-item]").click({ force: true }));
    await compare(b, "click disabled", slots, SEL);
    continue;
  }
  await each(b, (p) => inRoot(p, "[data-slot=toggle-group-item]:nth-child(2)").click());
  await wait(b, 50);
  await compare(b, "click 2nd", slots, SEL);
  await each(b, (p) => inRoot(p, "[data-slot=toggle-group-item]:nth-child(1)").click());
  await wait(b, 50);
  await compare(b, "click 1st", slots, SEL);
  await shot(b, `${name}-clicked`);
  for (const key of ["ArrowRight", "ArrowRight", "ArrowRight", "ArrowLeft", "End", "Home", "ArrowDown", "Space", "Enter"]) {
    await each(b, (p) => p.keyboard.press(key));
    await wait(b, 50);
    await compare(b, key, focused);
  }
  await compare(b, "after keys", slots, SEL);
  await each(b, (p) => p.keyboard.press("Tab"));
  await compare(b, "Tab leaves the group", focused);
  await each(b, (p) => p.keyboard.press("Shift+Tab"));
  await compare(b, "Shift+Tab returns to", focused);
}
await b.close();
