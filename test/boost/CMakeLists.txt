# -*- cmake -*-
#
# Copyright 2025 Dmitry Igrishin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required(VERSION 3.16)
project(dmitigr_boost_test)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../src")
include(dmitigr_boost)

set(Boost_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/lib-install")
set(Boost_USE_DEBUG_LIBS On)
set(Boost_USE_RELEASE_LIBS Off)
set(boost_libs "json" "date_time")
dmitigr_boost_build("${CMAKE_CURRENT_SOURCE_DIR}/lib-src"
  "${CMAKE_CURRENT_SOURCE_DIR}/lib-build"
  "${boost_libs}")

dmitigr_boost_find(REQUIRED COMPONENTS ${boost_libs})
