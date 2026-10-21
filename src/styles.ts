export interface EmojiStyle {
  id: string;
  label: string;
  dir: string;
  ext: "png" | "svg";
  available: boolean;
  note?: string;
}

export const EMOJI_STYLES: EmojiStyle[] = [
  { id: "apple", label: "Apple (iOS / macOS)", dir: "/emoji/apple", ext: "png", available: true },
  { id: "google", label: "Google (Android / Pixel / YouTube)", dir: "/emoji/google", ext: "png", available: true },
  { id: "microsoft", label: "Microsoft (Windows / Fluent)", dir: "/emoji/microsoft", ext: "svg", available: false, note: "brak zasobów" },
  { id: "twitter", label: "Twitter / X (Twemoji)", dir: "/twemoji", ext: "svg", available: true },
  { id: "samsung", label: "Samsung (One UI)", dir: "/emoji/samsung", ext: "png", available: false, note: "brak zasobów" },
];

export const getStyle = (id: string) =>
  EMOJI_STYLES.find((s) => s.id === id && s.available) ??
  EMOJI_STYLES.find((s) => s.id === "twitter")!;

/** Kolejne adresy do wypróbowania: wybrany styl (z FE0F i bez), potem Twemoji. */
export function imageCandidates(emoji: string, styleId: string): string[] {
  const codes = Array.from(emoji).map((c) => c.codePointAt(0)!.toString(16));
  const full = codes.join("-");
  const stripped = codes.filter((c) => c !== "fe0f").join("-");
  const s = getStyle(styleId);
  const tw = EMOJI_STYLES.find((x) => x.id === "twitter")!;
  const urls = [
    `${s.dir}/${full}.${s.ext}`,
    `${s.dir}/${stripped}.${s.ext}`,
    `${tw.dir}/${stripped}.svg`,
  ];
  return [...new Set(urls)];
}
