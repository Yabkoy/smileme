import compact from "emojibase-data/en/compact.json";
import type { CompactEmoji } from "emojibase";

export interface EmojiItem {
  emoji: string;
  label: string;
  search: string;
  skins: string[]; // warianty odcieni 1..5 (może być puste)
}

const GROUP_COMPONENT = 2; // swatche odcieni skóry, pomijamy

export const EMOJIS: EmojiItem[] = (compact as unknown as CompactEmoji[])
  .filter((e) => !!e.unicode && e.group !== undefined && e.group !== GROUP_COMPONENT)
  .map((e) => ({
    emoji: e.unicode,
    label: e.label,
    search: [e.label, ...(e.tags ?? []), ...(e.shortcodes ?? [])]
      .join(" ")
      .toLowerCase(),
    skins: (e.skins ?? []).map((s) => s.unicode).filter(Boolean),
  }));

export function searchEmojis(query: string): EmojiItem[] {
  const q = query.trim().toLowerCase();
  if (!q) return EMOJIS;
  return EMOJIS.filter((e) => e.search.includes(q));
}

/** Nazwa pliku Twemoji: kody hex po myślnikach, bez FE0F, o ile brak ZWJ (200D). */
export function twemojiFileName(emoji: string): string {
  let codes = Array.from(emoji).map((c) => c.codePointAt(0)!.toString(16));
  if (!codes.includes("200d")) codes = codes.filter((c) => c !== "fe0f");
  return codes.join("-");
}
