// Input OTP: the demo (6 digits) and Pattern: focus by clicking a slot,
// typing (and refused characters), the active slot and fake caret,
// Backspace, arrows, Home/End, selecting, pasting, clicking a filled slot.
import { both, compare, each, focused, inRoot, shotRoot as shot, slots, wait } from "./lib.mjs";

const state = () => {
  const root = document.querySelector("[data-parity-root]");
  const input = root.querySelector("input");
  const s = [...root.querySelectorAll("[data-slot=input-otp-slot]")].map((el) =>
    `${el.innerText.trim() || "_"}${el.dataset.active === "true" ? "*" : ""}${el.querySelector(".animate-caret-blink") ? "|" : ""}`);
  return `${s.join(" ")} value=${JSON.stringify(input.value)} sel=${input.selectionStart}-${input.selectionEnd} focus=${document.activeElement === input}`;
};
// The transparent input lies over the slots: click where the slot is.
const clickSlot = async (p, n) => {
  const r = await inRoot(p, `[data-slot=input-otp-slot] >> nth=${n - 1}`).boundingBox();
  await p.mouse.click(r.x + r.width / 2, r.y + r.height / 2);
};
const b = await both(undefined, { permissions: ["clipboard-read", "clipboard-write"] });

for (const [title, ref, typing] of [["Demo", "input-otp-demo", "12a3"], ["Pattern", "input-otp-pattern", "a1-B"]]) {
  console.log(`-- ${title}`);
  await b.open("input_otp", title, ref);
  if (title === "Demo") {
    await compare(b, "initial", slots, "[data-slot=input-otp], [data-slot=input-otp-group], [data-slot=input-otp-slot], [data-slot=input-otp-separator], input, [data-input-otp-container]");
    await compare(b, "input attrs", () => { const i = document.querySelector("[data-parity-root] input"); return [...i.attributes].filter((a) => a.name !== "id" && a.name !== "style").map((a) => `${a.name}=${a.value}`).sort(); });
  }
  await each(b, (p) => clickSlot(p, 2));
  await wait(b, 50);
  await compare(b, "click slot 2", state);
  await shot(b, `otp-${title}-focused`);
  for (const ch of typing) {
    await each(b, (p) => p.keyboard.type(ch));
    await wait(b, 30);
    await compare(b, `type ${ch}`, state);
  }
  await shot(b, `otp-${title}-typed`);
  for (const key of ["ArrowLeft", "ArrowLeft", "Backspace", "End", "Home", "ArrowRight", "Delete", "Backspace", "Backspace"]) {
    await each(b, (p) => p.keyboard.press(key));
    await wait(b, 30);
    await compare(b, key, state);
  }
}
// Paste into the demo, then click a filled slot.
await b.open("input_otp", "Demo", "input-otp-demo");
await each(b, (p) => clickSlot(p, 1));
await each(b, (p) => p.evaluate(() => navigator.clipboard.writeText("98 76 54")));
await each(b, (p) => p.keyboard.press("Control+V"));
await wait(b, 50);
await compare(b, "paste '98 76 54'", state);
await each(b, (p) => p.evaluate(() => navigator.clipboard.writeText("123456")));
await each(b, (p) => p.keyboard.press("Control+A"));
await each(b, (p) => p.keyboard.press("Control+V"));
await wait(b, 50);
await compare(b, "select all, paste 123456", state);
await shot(b, "otp-pasted");
await each(b, (p) => p.keyboard.type("7"));
await compare(b, "type when full", state);
await each(b, (p) => clickSlot(p, 2));
await wait(b, 50);
await compare(b, "click filled slot 2", state);
await each(b, (p) => p.keyboard.type("0"));
await compare(b, "type over it", state);
await each(b, (p) => p.keyboard.press("Tab"));
await compare(b, "Tab out", state);
await b.close();
