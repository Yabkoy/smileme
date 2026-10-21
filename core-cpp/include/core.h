#pragma once

#include <string>
#include <string_view>
#include <vector>

namespace emoji {

const char* version();

struct Item {
  std::string hex;                 // np. "2764-fe0f"
  std::string label;
  int group = 0;
  std::string search;              // małe litery: etykieta + tagi + shortcody
  std::vector<std::string> skins;  // warianty odcieni 1..5 (może być puste)
};

std::vector<Item> parseItems(const std::string& json_text);
std::vector<Item> loadItems(const std::string& path);

// Obcina białe znaki i zamienia litery ASCII na małe.
std::string trimLower(std::string_view s);

// Pusty ciąg zwraca wszystko. Wskaźniki wskazują na elementy z `items`.
std::vector<const Item*> search(const std::vector<Item>& items, std::string_view query);

// tone 0 = domyślny, 1..5 = odcień. Brak wariantu => hex bez zmian.
std::string applySkin(const Item& item, int tone);

// Usuwa segmenty "fe0f" z kodu hex.
std::string stripVariation(const std::string& hex);

// Kolejne ścieżki do wypróbowania: wybrany styl (pełna nazwa, bez FE0F), potem Twitter.
// Style bez zasobów (np. microsoft, samsung) spadają na Twitter.
std::vector<std::string> imageCandidates(const std::string& hex, const std::string& style);

}  // namespace emoji
