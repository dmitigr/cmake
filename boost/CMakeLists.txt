cmake_minimum_required(VERSION 3.16)
project(dmitigr_boost_test)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
include(dmitigr_boost)

set(Boost_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/boost-install")
set(Boost_USE_DEBUG_LIBS On)
set(Boost_USE_RELEASE_LIBS Off)
set(boost_libs "json" "date_time")
dmitigr_boost_build("${CMAKE_CURRENT_SOURCE_DIR}/boost"
  "${CMAKE_CURRENT_SOURCE_DIR}/boost-build"
  "${boost_libs}")

find_package(Boost REQUIRED COMPONENTS ${boost_libs}
  PATHS "${Boost_ROOT}" NO_DEFAULT_PATH)
