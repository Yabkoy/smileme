import { cpSync, existsSync, mkdirSync, readdirSync } from "node:fs";

for (const set of ["apple", "google"]) {
  const src = `node_modules/emoji-datasource-${set}/img/${set}/64`;
  const dest = `public/emoji/${set}`;
  if (!existsSync(src)) {
    console.warn(`Brak ${src}, pomijam ${set} (sprawdź: ls node_modules/emoji-datasource-${set}/img)`);
    continue;
  }
  mkdirSync(dest, { recursive: true });
  for (const f of readdirSync(src)) {
    if (f.endsWith(".png")) cpSync(`${src}/${f}`, `${dest}/${f}`);
  }
  console.log("Skopiowano", set);
}
