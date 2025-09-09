cmake_minimum_required(VERSION 3.16)
project(dmitigr_boost_test)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
include(dmitigr_boost)

set(Boost_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/lib-install")
set(Boost_USE_DEBUG_LIBS On)
set(Boost_USE_RELEASE_LIBS Off)
set(boost_libs "json" "date_time")
dmitigr_boost_build("${CMAKE_CURRENT_SOURCE_DIR}/lib-src"
  "${CMAKE_CURRENT_SOURCE_DIR}/lib-build"
  "${boost_libs}")

dmitigr_boost_find(REQUIRED COMPONENTS ${boost_libs})
