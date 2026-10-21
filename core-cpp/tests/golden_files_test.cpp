#include <gtest/gtest.h>

#include <filesystem>
#include <fstream>
#include <string>

#include "core.h"

namespace fs = std::filesystem;

TEST(Core, Version) { EXPECT_STREQ(emoji::version(), "0.1.0"); }

class GoldenFiles : public ::testing::TestWithParam<const char*> {};

TEST_P(GoldenFiles, ExistAndNotEmpty) {
  fs::path p = fs::path(GOLDEN_DIR) / GetParam();
  ASSERT_TRUE(fs::exists(p)) << p;
  std::ifstream f(p);
  std::string content((std::istreambuf_iterator<char>(f)), {});
  EXPECT_GT(content.size(), 2u);
}

INSTANTIATE_TEST_SUITE_P(All, GoldenFiles,
                         ::testing::Values("search.json", "skin.json", "assets.json"));
