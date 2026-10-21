import { useEffect, useState } from "react";
import { imageCandidates } from "../styles";
import { usePickerStore } from "../store";

export function Twemoji({
  emoji,
  size = 28,
  styleId,
}: {
  emoji: string;
  size?: number;
  styleId?: string;
}) {
  const global = usePickerStore((s) => s.style);
  const style = styleId ?? global;
  const [attempt, setAttempt] = useState(0);

  useEffect(() => setAttempt(0), [emoji, style]);

  if (!emoji) return null;
  const urls = imageCandidates(emoji, style);

  // Ostateczny fallback: znak systemowy
  if (attempt >= urls.length) {
    return <span style={{ fontSize: size * 0.85, lineHeight: 1 }}>{emoji}</span>;
  }

  return (
    <img
      src={urls[attempt]}
      alt={emoji}
      width={size}
      height={size}
      loading="lazy"
      decoding="async"
      draggable={false}
      onError={() => setAttempt((a) => a + 1)}
    />
  );
}
