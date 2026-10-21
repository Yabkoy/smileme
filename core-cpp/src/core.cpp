#include "core.h"

#include <algorithm>
#include <cctype>
#include <fstream>
#include <sstream>
#include <stdexcept>

#include <nlohmann/json.hpp>

namespace emoji {

const char* version() { return "0.1.0"; }

std::vector<Item> parseItems(const std::string& json_text) {
  auto j = nlohmann::json::parse(json_text);
  std::vector<Item> out;
  out.reserve(j.size());
  for (const auto& e : j) {
    Item it;
    it.hex = e.at("hex").get<std::string>();
    it.label = e.at("label").get<std::string>();
    it.group = e.value("group", 0);
    it.search = e.at("search").get<std::string>();
    it.skins = e.value("skins", std::vector<std::string>{});
    out.push_back(std::move(it));
  }
  return out;
}

std::vector<Item> loadItems(const std::string& path) {
  std::ifstream f(path, std::ios::binary);
  if (!f) throw std::runtime_error("Nie mozna otworzyc: " + path);
  std::stringstream ss;
  ss << f.rdbuf();
  return parseItems(ss.str());
}

std::string trimLower(std::string_view s) {
  auto isSpace = [](unsigned char c) { return std::isspace(c) != 0; };
  size_t b = 0, e = s.size();
  while (b < e && isSpace(s[b])) ++b;
  while (e > b && isSpace(s[e - 1])) --e;
  std::string out(s.substr(b, e - b));
  std::transform(out.begin(), out.end(), out.begin(),
                 [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
  return out;
}

std::vector<const Item*> search(const std::vector<Item>& items, std::string_view query) {
  const std::string q = trimLower(query);
  std::vector<const Item*> out;
  for (const auto& it : items) {
    if (q.empty() || it.search.find(q) != std::string::npos) out.push_back(&it);
  }
  return out;
}

std::string applySkin(const Item& item, int tone) {
  if (tone >= 1 && static_cast<size_t>(tone) <= item.skins.size()) {
    return item.skins[static_cast<size_t>(tone) - 1];
  }
  return item.hex;
}

std::string stripVariation(const std::string& hex) {
  std::string out;
  size_t start = 0;
  while (start <= hex.size()) {
    size_t dash = hex.find('-', start);
    std::string part = hex.substr(start, dash == std::string::npos ? std::string::npos : dash - start);
    if (part != "fe0f") {
      if (!out.empty()) out += '-';
      out += part;
    }
    if (dash == std::string::npos) break;
    start = dash + 1;
  }
  return out;
}

std::vector<std::string> imageCandidates(const std::string& hex, const std::string& style) {
  const bool available = style == "apple" || style == "google" || style == "twitter";
  const std::string s = available ? style : "twitter";
  const std::string stripped = stripVariation(hex);

  const std::vector<std::string> all = {
      "assets/" + s + "/" + hex + ".png",
      "assets/" + s + "/" + stripped + ".png",
      "assets/twitter/" + stripped + ".png",
  };

  std::vector<std::string> out;
  for (const auto& u : all) {
    if (std::find(out.begin(), out.end(), u) == out.end()) out.push_back(u);
  }
  return out;
}

}  // namespace emoji
