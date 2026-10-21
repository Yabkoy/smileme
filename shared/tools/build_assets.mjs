import { cpSync, existsSync, mkdirSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import sharp from "sharp";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "../assets");
const nm = join(here, "node_modules");

// Twitter/Twemoji: SVG -> PNG 64px
const svgDir = join(nm, "@twemoji/svg");
const twOut = join(out, "twitter");
mkdirSync(twOut, { recursive: true });
for (const f of readdirSync(svgDir).filter((f) => f.endsWith(".svg"))) {
  await sharp(join(svgDir, f), { density: 300 })
    .resize(64, 64)
    .png()
    .toFile(join(twOut, f.replace(/\.svg$/, ".png")));
}
console.log("twitter: gotowe");

// Google i Apple: gotowe PNG 64px
for (const set of ["google", "apple"]) {
  const src = join(nm, `emoji-datasource-${set}/img/${set}/64`);
  if (!existsSync(src)) {
    console.warn(`Brak ${src}, pomijam ${set}`);
    continue;
  }
  const dest = join(out, set);
  mkdirSync(dest, { recursive: true });
  cpSync(src, dest, { recursive: true });
  console.log(`${set}: gotowe`);
}
