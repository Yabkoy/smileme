import { create } from "zustand";
import { persist } from "zustand/middleware";

export const SKIN_TONES = [
  { id: 0, label: "Domyślny", color: "#FFC83D" },
  { id: 1, label: "Jasny", color: "#F7DECE" },
  { id: 2, label: "Średnio jasny", color: "#F3D2A2" },
  { id: 3, label: "Średni", color: "#D5AB88" },
  { id: 4, label: "Średnio ciemny", color: "#AF7E57" },
  { id: 5, label: "Ciemny", color: "#7C533E" },
] as const;

interface PickerState {
  tone: number;
  setTone: (tone: number) => void;
  style: string;
  setStyle: (style: string) => void;
}

export const usePickerStore = create<PickerState>()(
  persist(
    (set) => ({
      tone: 0,
      setTone: (tone) => set({ tone }),
      style: "twitter",
      setStyle: (style) => set({ style }),
    }),
    { name: "emoji-picker-settings" },
  ),
);
