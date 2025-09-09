cmake_minimum_required(VERSION 4.0)
project(dmitigr_openssl_test)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
include(dmitigr_openssl)

set(OPENSSL_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib-install")
dmitigr_openssl_build("${CMAKE_CURRENT_SOURCE_DIR}/lib-src"
  "${CMAKE_CURRENT_SOURCE_DIR}/lib-build" "enable-apps;enable-shared")

set(OPENSSL_USE_STATIC_LIBS True)
dmitigr_openssl_find(REQUIRED)
