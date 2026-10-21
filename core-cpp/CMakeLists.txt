cmake_minimum_required(VERSION 3.20)
project(emoji_core LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(emoji_core STATIC src/core.cpp)
target_include_directories(emoji_core PUBLIC include)

enable_testing()
include(FetchContent)
FetchContent_Declare(googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

add_executable(core_tests tests/golden_files_test.cpp)
target_link_libraries(core_tests PRIVATE emoji_core GTest::gtest_main)
target_compile_definitions(core_tests PRIVATE
  GOLDEN_DIR="${CMAKE_CURRENT_SOURCE_DIR}/../shared/golden")

include(GoogleTest)
gtest_discover_tests(core_tests)
