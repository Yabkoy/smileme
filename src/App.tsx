import { invoke } from "@tauri-apps/api/core";
import { useEffect, useMemo, useRef, useState } from "react";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { Twemoji } from "./components/Twemoji";
import { Settings } from "./components/Settings";
import { searchEmojis, type EmojiItem } from "./emoji";
import { SKIN_TONES, usePickerStore } from "./store";

export default function App() {
  const [query, setQuery] = useState("");
  const [view, setView] = useState<"picker" | "settings">("picker");
  const inputRef = useRef<HTMLInputElement>(null);
  const { tone, setTone } = usePickerStore();

  const results = useMemo(() => searchEmojis(query), [query]);

  const variant = (item: EmojiItem) =>
    tone > 0 && item.skins[tone - 1] ? item.skins[tone - 1] : item.emoji;

  const pick = async (item: EmojiItem) => {
  try {
    await navigator.clipboard.writeText(variant(item));
  } catch (err) {
    console.error("Schowek:", err);
  }
  await invoke("paste_and_hide");
};

  // Przy każdym pokazaniu okna (focus): wróć do pickera, wyczyść pole i aktywuj wyszukiwarkę
  useEffect(() => {
    const focusInput = () => {
      setView("picker");
      setQuery("");
      setTimeout(() => {
        inputRef.current?.focus();
        inputRef.current?.select();
      }, 0);
    };
    focusInput();

    const unlisten = getCurrentWindow().onFocusChanged(({ payload: focused }) => {
      if (focused) focusInput();
    });
    return () => {
      unlisten.then((f) => f());
    };
  }, []);

  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Escape") getCurrentWindow().hide();
    if (e.key === "Enter" && view === "picker" && results[0]) pick(results[0]);
  };

  return (
    <main
      className="flex h-screen flex-col gap-2 bg-neutral-900 p-3 text-white"
      onKeyDown={onKeyDown}
    >
      {view === "settings" ? (
        <Settings onBack={() => setView("picker")} />
      ) : (
        <>
          <div className="flex gap-2">
            <input
              ref={inputRef}
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Szukaj emoji (np. smile, heart, kot)…"
              className="w-full rounded-lg bg-neutral-800 px-3 py-2 text-sm outline-none ring-1 ring-neutral-700 focus:ring-blue-500"
              autoFocus
            />
            <button
              title="Ustawienia"
              onClick={() => setView("settings")}
              className="rounded-lg px-2 text-lg hover:bg-neutral-700"
            >
              ⚙
            </button>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400">Odcień:</span>
            {SKIN_TONES.map((t) => (
              <button
                key={t.id}
                title={t.label}
                onClick={() => setTone(t.id)}
                className={`h-5 w-5 rounded-full ring-offset-2 ring-offset-neutral-900 ${
                  tone === t.id ? "ring-2 ring-blue-500" : "ring-1 ring-neutral-600"
                }`}
                style={{ backgroundColor: t.color }}
              />
            ))}
          </div>

          <div className="grid flex-1 grid-cols-8 content-start gap-1 overflow-y-auto">
            {results.map((item) => (
              <button
                key={`${item.emoji}-${item.label}`}
                title={item.label}
                onClick={() => pick(item)}
                className="flex h-10 w-10 items-center justify-center rounded-md hover:bg-neutral-700"
              >
                <Twemoji emoji={variant(item)} />
              </button>
            ))}
            {results.length === 0 && (
              <p className="col-span-8 py-6 text-center text-sm text-neutral-500">
                Brak wyników
              </p>
            )}
          </div>

          <p className="text-center text-[11px] text-neutral-500">
            Enter: wybierz pierwsze · Esc: zamknij
          </p>
        </>
      )}
    </main>
  );
}
