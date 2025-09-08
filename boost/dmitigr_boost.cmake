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

# @brief Builds Boost libraries and installs them under `${Boost_ROOT}`.
#
# @details The behavior of this function depends on the following variables:
#   - `Boost_ROOT` - a path where to install Boost (if not installed yet);
#   - `Boost_USE_STATIC_LIBS` - build the static libraries. Considered as "On"
#   if not set;
#   - `Boost_USE_STATIC_RUNTIME` - link to the static runtime. Considered as
#   "Off" if not set;
#   - `Boost_USE_MULTITHREADED` - build with multi-thread support. Considered
#   as "On" if not set;
#   - `Boost_USE_DEBUG_LIBS` - build the debug variant of libraries;
#   - `Boost_USE_RELEASE_LIBS` - build the release variant of libraries.
# Note, `Boost_USE_DEBUG_LIBS` and `Boost_USE_RELEASE_LIBS` are mutually
# exclusive and mandatory.
#
# @param boost_src_root A path where to look for Boost sources.
# @param boost_build_root A path where to build Boost.
# @param boost_libs A list of libraries to build (default all the libraries).
function(dmitigr_boost_build boost_src_root boost_build_root boost_libs)
  if(NOT Boost_ROOT)
    message(FATAL_ERROR "dmitigr_boost_build(): Boost_ROOT must not be empty")
  endif()

  if(NOT boost_src_root OR NOT boost_build_root OR NOT boost_libs)
    message(FATAL_ERROR "dmitigr_boost_build(): invalid arguments")
  endif()

  if(Boost_USE_STATIC_LIBS)
    set(boost_link "static")
  else()
    set(boost_link "shared")
  endif()

  if(Boost_USE_STATIC_RUNTIME)
    set(boost_runtime_link "static")
  else()
    set(boost_runtime_link "shared")
  endif()

  if(NOT DEFINED Boost_USE_MULTITHREADED OR Boost_USE_MULTITHREADED)
    set(boost_threading "multi")
  else()
    set(boost_threading "single")
  endif()

  if(Boost_USE_DEBUG_LIBS AND Boost_USE_RELEASE_LIBS)
    message(FATAL_ERROR "Boost_USE_DEBUG_LIBS and Boost_USE_RELEASE_LIBS must differ")
  elseif(Boost_USE_DEBUG_LIBS)
    set(boost_variant "debug")
  elseif(Boost_USE_RELEASE_LIBS)
    set(boost_variant "release")
  else()
    message(FATAL_ERROR "Either Boost_USE_DEBUG_LIBS or Boost_USE_RELEASE_LIBS must be set")
  endif()

  find_package(Boost COMPONENTS ${boost_libs}
    PATHS "${Boost_ROOT}" NO_DEFAULT_PATH)
  foreach(lib ${boost_libs})
    string(TOUPPER "${lib}" LIB)
    if(NOT Boost_${LIB}_FOUND)
      set(Boost_FOUND FALSE)
      break()
    endif()
  endforeach()

  if(NOT Boost_FOUND)
    set(boost_bootstrap_script "${boost_src_root}/bootstrap")
    if(WIN32)
      list(TRANSFORM boost_bootstrap_script APPEND ".bat")
    else()
      list(TRANSFORM boost_bootstrap_script APPEND ".sh")
    endif()

    execute_process(COMMAND "${boost_bootstrap_script}"
      WORKING_DIRECTORY "${boost_src_root}"
      RESULT_VARIABLE status
    )
    if(NOT status EQUAL 0)
      message(FATAL_ERROR "cannot bootstrap Boost: ${status}")
    endif()

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      set(toolset "gcc")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
      set(toolset "msvc")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
      set(toolset "clang")
    else()
      message(FATAL_ERROR "cannot build Boost with ${CMAKE_CXX_COMPILER_ID}")
    endif()

    cmake_host_system_information(RESULT cpu_core_count
      QUERY NUMBER_OF_PHYSICAL_CORES)

    foreach(lib ${boost_libs})
      list(APPEND with_libs "--with-${lib}")
    endforeach()

    execute_process(COMMAND "${boost_src_root}/b2"
      "-a"
      "-q"
      "-j" "${cpu_core_count}"
      "address-model=64"
      "toolset=${toolset}"
      "link=${boost_link}"
      "runtime-link=${boost_runtime_link}"
      "variant=${boost_variant}"
      "threading=${boost_threading}"
      "install"
      "--reconfigure"
      "--prefix=${Boost_ROOT}"
      "--build-type=minimal"
      "--build-dir=${boost_build_root}"
      "--layout=tagged"
      ${with_libs}
      WORKING_DIRECTORY "${boost_src_root}"
      RESULT_VARIABLE status
    )
    if(NOT status EQUAL 0)
      message(FATAL_ERROR "cannot build Boost: ${status}")
    endif()
  endif()
endfunction()
