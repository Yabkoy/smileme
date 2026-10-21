import { EMOJI_STYLES } from "../styles";
import { usePickerStore } from "../store";
import { Twemoji } from "./Twemoji";

const PREVIEW = ["😀", "❤️", "👍", "🔥", "🐱"];

export function Settings({ onBack }: { onBack: () => void }) {
  const { style, setStyle } = usePickerStore();

  return (
    <div className="flex flex-1 flex-col gap-2 overflow-y-auto">
      <div className="flex items-center gap-2">
        <button
          onClick={onBack}
          className="rounded-md px-2 py-1 text-sm text-neutral-300 hover:bg-neutral-700"
        >
          ← Wróć
        </button>
        <h2 className="text-sm font-semibold">Styl emoji</h2>
      </div>

      {EMOJI_STYLES.map((s) => (
        <button
          key={s.id}
          disabled={!s.available}
          onClick={() => setStyle(s.id)}
          className={`flex flex-col gap-1 rounded-lg p-2 text-left ring-1 ${
            style === s.id ? "bg-neutral-800 ring-blue-500" : "ring-neutral-700"
          } ${s.available ? "hover:bg-neutral-800" : "cursor-not-allowed opacity-40"}`}
        >
          <span className="text-sm">
            {s.label}
            {s.note && <span className="ml-2 text-xs text-neutral-400">({s.note})</span>}
          </span>
          <span className="flex gap-1">
            {PREVIEW.map((e) => (
              <Twemoji key={e} emoji={e} size={24} styleId={s.id} />
            ))}
          </span>
        </button>
      ))}
    </div>
  );
}
