import { readFileSync } from "node:fs";

const data = JSON.parse(readFileSync(new URL("../data/emoji.json", import.meta.url), "utf8"));
if (data.length < 1500) {
  console.error(`Za malo emoji: ${data.length}`);
  process.exit(1);
}
console.log(`OK: ${data.length} emoji`);
