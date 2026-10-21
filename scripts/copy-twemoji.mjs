import { cpSync, mkdirSync, readdirSync } from "node:fs";

const src = "node_modules/@twemoji/svg";
const dest = "public/twemoji";

mkdirSync(dest, { recursive: true });
for (const file of readdirSync(src)) {
  if (file.endsWith(".svg")) cpSync(`${src}/${file}`, `${dest}/${file}`);
}
console.log("Twemoji skopiowane do", dest);
