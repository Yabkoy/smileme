import SwiftUI
import EmojiCore

private let skinTones: [(id: Int, label: String, color: Color)] = [
    (0, "Domyślny", Color(red: 1.00, green: 0.78, blue: 0.24)),
    (1, "Jasny", Color(red: 0.97, green: 0.87, blue: 0.81)),
    (2, "Średnio jasny", Color(red: 0.95, green: 0.82, blue: 0.64)),
    (3, "Średni", Color(red: 0.84, green: 0.67, blue: 0.53)),
    (4, "Średnio ciemny", Color(red: 0.69, green: 0.49, blue: 0.34)),
    (5, "Ciemny", Color(red: 0.49, green: 0.33, blue: 0.24)),
]

struct EmojiImage: View {
    let hex: String
    let style: String
    var size: CGFloat = 28

    var body: some View {
        if let img = ImageCache.image(hex: hex, style: style) {
            Image(nsImage: img)
                .resizable()
                .interpolation(.high)
                .frame(width: size, height: size)
        } else {
            // Ostateczny fallback: znak systemowy
            Text(EmojiCore.string(fromHex: hex))
                .font(.system(size: size * 0.8))
                .frame(width: size, height: size)
        }
    }
}

private struct EmojiCell: View {
    let item: EmojiItem
    @ObservedObject var vm: PickerViewModel
    let onPick: (String) -> Void
    @State private var hovering = false

    var body: some View {
        Button { onPick(vm.text(for: item)) } label: {
            EmojiImage(hex: vm.hex(for: item), style: vm.style)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 6)
                    .fill(hovering ? Color.primary.opacity(0.15) : .clear))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(item.label)
        .onHover { hovering = $0 }
    }
}

struct PickerView: View {
    @ObservedObject var vm: PickerViewModel
    let onPick: (String) -> Void
    let onClose: () -> Void

    @FocusState private var searchFocused: Bool
    private let columns = Array(repeating: GridItem(.fixed(44), spacing: 2), count: 8)

    var body: some View {
        Group {
            if vm.showingSettings {
                SettingsView(vm: vm)
            } else {
                picker
            }
        }
        .padding(12)
        .frame(width: 420, height: 480)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onExitCommand { onClose() }
    }

    private var picker: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Szukaj emoji (np. smile, heart)…", text: $vm.query)
                    .textFieldStyle(.roundedBorder)
                    .focused($searchFocused)
                    .onSubmit {
                        if let first = vm.results.first { onPick(vm.text(for: first)) }
                    }
                Button { vm.showingSettings = true } label: { Image(systemName: "gearshape") }
                    .buttonStyle(.borderless)
                    .help("Ustawienia")
            }

            HStack(spacing: 8) {
                Text("Odcień:").font(.caption).foregroundStyle(.secondary)
                ForEach(skinTones, id: \.id) { t in
                    Circle()
                        .fill(t.color)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(vm.tone == t.id ? Color.accentColor : Color.gray.opacity(0.5),
                                                 lineWidth: vm.tone == t.id ? 2.5 : 1))
                        .onTapGesture { vm.tone = t.id }
                        .help(t.label)
                }
                Spacer()
            }

            let results = vm.results
            if results.isEmpty {
                Spacer()
                Text("Brak wyników").foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(results, id: \.hex) { item in
                            EmojiCell(item: item, vm: vm, onPick: onPick)
                        }
                    }
                }
            }

            Text("Enter: wybierz pierwsze · Esc: zamknij")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .onAppear { searchFocused = true }
        .onReceive(vm.$focusToken) { _ in
            DispatchQueue.main.async { searchFocused = true }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var vm: PickerViewModel
    private let preview = ["1f600", "2764-fe0f", "1f44d", "1f525", "1f431"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("← Wróć") { vm.showingSettings = false }
                    .buttonStyle(.borderless)
                Text("Styl emoji").font(.headline)
                Spacer()
            }

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(EmojiCore.styles) { s in
                        Button { vm.style = s.id } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(s.label + (s.available ? "" : " (brak zasobów)"))
                                HStack(spacing: 4) {
                                    ForEach(preview, id: \.self) { EmojiImage(hex: $0, style: s.id, size: 24) }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(vm.style == s.id ? Color.accentColor : Color.gray.opacity(0.4),
                                        lineWidth: vm.style == s.id ? 2 : 1))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!s.available)
                        .opacity(s.available ? 1 : 0.4)
                    }
                }
            }
        }
    }
}
