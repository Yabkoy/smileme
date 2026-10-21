#include <gtest/gtest.h>

#include <algorithm>
#include <filesystem>
#include <fstream>

#include <nlohmann/json.hpp>

#include "core.h"

namespace fs = std::filesystem;
using nlohmann::json;

static json readGolden(const char* name) {
  fs::path p = fs::path(GOLDEN_DIR) / name;
  std::ifstream f(p, std::ios::binary);
  EXPECT_TRUE(f.good()) << p;
  return json::parse(f);
}

static const std::vector<emoji::Item>& items() {
  static const auto v = emoji::loadItems(DATA_FILE);
  return v;
}

TEST(Core, Version) { EXPECT_STREQ(emoji::version(), "0.1.0"); }

TEST(Core, StripVariation) {
  EXPECT_EQ(emoji::stripVariation("2764-fe0f"), "2764");
  EXPECT_EQ(emoji::stripVariation("1f600"), "1f600");
  EXPECT_EQ(emoji::stripVariation("1f468-200d-1f4bb"), "1f468-200d-1f4bb");
}

TEST(Golden, Search) {
  for (const auto& c : readGolden("search.json")) {
    const std::string q = c.at("query").get<std::string>();
    SCOPED_TRACE("query: '" + q + "'");
    auto res = emoji::search(items(), q);

    if (c.contains("expectCount")) EXPECT_EQ(res.size(), c["expectCount"].get<size_t>());
    if (c.contains("expectCountAtLeast")) EXPECT_GE(res.size(), c["expectCountAtLeast"].get<size_t>());
    if (c.contains("mustContain")) {
      for (const auto& hex : c["mustContain"]) {
        const std::string h = hex.get<std::string>();
        bool found = std::any_of(res.begin(), res.end(),
                                 [&](const emoji::Item* it) { return it->hex == h; });
        EXPECT_TRUE(found) << "brak " << h;
      }
    }
  }
}

TEST(Golden, Skin) {
  for (const auto& c : readGolden("skin.json")) {
    const std::string base = c.at("base").get<std::string>();
    SCOPED_TRACE("base: " + base);
    auto it = std::find_if(items().begin(), items().end(),
                           [&](const emoji::Item& i) { return i.hex == base; });
    ASSERT_NE(it, items().end()) << "brak emoji " << base << " w danych";
    EXPECT_EQ(emoji::applySkin(*it, c.at("tone").get<int>()), c.at("expect").get<std::string>());
  }
}

TEST(Golden, Assets) {
  for (const auto& c : readGolden("assets.json")) {
    const std::string hex = c.at("hex").get<std::string>();
    const std::string style = c.at("style").get<std::string>();
    SCOPED_TRACE(style + "/" + hex);
    EXPECT_EQ(emoji::imageCandidates(hex, style), c.at("expect").get<std::vector<std::string>>());
  }
}
