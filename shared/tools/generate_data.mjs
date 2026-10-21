import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const src = join(here, "node_modules/emojibase-data/en/compact.json");
const outDir = join(here, "../data");
const GROUP_COMPONENT = 2; // swatche odcieni skóry, pomijamy

const hex = (s) =>
  Array.from(s).map((c) => c.codePointAt(0).toString(16)).join("-");

const compact = JSON.parse(readFileSync(src, "utf8"));

const items = compact
  .filter((e) => e.unicode && e.group !== undefined && e.group !== GROUP_COMPONENT)
  .map((e) => ({
    hex: hex(e.unicode),
    label: e.label,
    group: e.group,
    search: [e.label, ...(e.tags ?? []), ...(e.shortcodes ?? [])]
      .join(" ")
      .toLowerCase(),
    skins: (e.skins ?? []).filter((s) => s.unicode).map((s) => hex(s.unicode)),
  }));

mkdirSync(outDir, { recursive: true });
writeFileSync(join(outDir, "emoji.json"), JSON.stringify(items));
console.log(`Zapisano ${items.length} emoji`);
