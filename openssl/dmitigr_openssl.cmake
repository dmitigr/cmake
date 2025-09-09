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

set(dmitigr_openssl_libdir "lib")

# @brief Attempts to find OpenSSL in `${OPENSSL_ROOT_DIR}`.
macro(dmitigr_openssl_find)
  find_package(OpenSSL ${ARGV}
    PATHS "${OPENSSL_ROOT_DIR}/${dmitigr_openssl_libdir}/cmake" NO_DEFAULT_PATH)
endmacro()

# @brief Builds OpenSSL libraries and installs them under `${OPENSSL_ROOT_DIR}`.
#
# @details The behavior of this function depends on the following variables:
#   - `OPENSSL_ROOT_DIR` - a path where to install OpenSSL (if not installed yet);
#   - `OPENSSL_MSVC_STATIC_RT` - link to the static runtime. Considered as "Off"
#   if not set.
#
# @param openssl_src_root A path where to look for OpenSSL sources.
# @param openssl_build_root A path where to build OpenSSL.
# @param openssl_configure_args A list of arguments to pass to the Configure
# script. It can be used both to override the default configure options used
# by this function and to add new configuration options.
function(dmitigr_openssl_build openssl_src_root openssl_build_root
    openssl_configure_args)
  if(NOT OPENSSL_ROOT_DIR)
    message(FATAL_ERROR "dmitigr_openssl_build(): OPENSSL_ROOT_DIR must not be empty")
  endif()

  if(NOT openssl_src_root OR NOT openssl_build_root)
    message(FATAL_ERROR "dmitigr_openssl_build(): invalid arguments")
  endif()

  find_package(Perl REQUIRED)
  if(PERL_VERSION_STRING VERSION_LESS "5.10.0")
    message(FATAL_ERROR "Perl 5.10.0 or later required")
  endif()

  set(OPENSSL_USE_STATIC_LIBS True)
  dmitigr_openssl_find(OPTIONAL)
  if(NOT OpenSSL_FOUND)
    execute_process(COMMAND "cmake"
      "-E" "make_directory" "${openssl_build_root}"
      RESULT_VARIABLE status
    )
    if(NOT status EQUAL 0)
      message(FATAL_ERROR "cannot make directory ${openssl_build_root}: ${status}")
    endif()

    cmake_host_system_information(RESULT cpu_core_count
      QUERY NUMBER_OF_PHYSICAL_CORES)

    if(WIN32)
      set(openssl_configure "perl" "${openssl_src_root}/Configure" "VC-WIN64A")
      set(openssl_make "nmake")
    else()
      set(openssl_configure "${openssl_src_root}/Configure")
      set(openssl_make "make" "--jobs=${cpu_core_count}")
    endif()

    set(openssl_configure_args
      "no-apps"
      "no-atexit"
      "no-dso"
      "no-deprecated"
      "no-legacy"
      "no-shared"
      "no-pinshared"
      "no-tests"
      "no-zlib"
      "enable-threads"
      "enable-thread-pool"
      "enable-default-thread-pool"
      ${openssl_configure_args}
    )
    if(APPLE)
      # Note, the CMAKE_OSX_SYSROOT is based on the CMAKE_OSX_DEPLOYMENT_TARGET.
      set(orig_cflags $ENV{CFLAGS})
      set(ENV{CFLAGS} "-L ${openssl_build_root}")
    elseif(WIN32)
      if(OPENSSL_MSVC_STATIC_RT)
        set(orig_cflags $ENV{CFLAGS})
        set(ENV{CFLAGS} "/MT")
      endif()
    endif()
    execute_process(COMMAND ${openssl_configure}
      "--prefix=${OPENSSL_ROOT_DIR}"
      "--libdir=${dmitigr_openssl_libdir}"
      ${openssl_configure_args}
      WORKING_DIRECTORY "${openssl_build_root}"
      RESULT_VARIABLE status
    )
    if(NOT status EQUAL 0)
      message(FATAL_ERROR "cannot configure OpenSSL: ${status}")
    endif()

    execute_process(COMMAND ${openssl_make}
      "build_sw"
      WORKING_DIRECTORY "${openssl_build_root}"
      RESULT_VARIABLE status
    )
    if(NOT status EQUAL 0)
      message(FATAL_ERROR "cannot build OpenSSL: ${status}")
    endif()

    execute_process(COMMAND ${openssl_make}
      "install_sw"
      WORKING_DIRECTORY "${openssl_build_root}"
      RESULT_VARIABLE status
    )
    if(NOT status EQUAL 0)
      message(FATAL_ERROR "cannot install OpenSSL: ${status}")
    endif()

    if(DEFINED orig_cflags)
      set(ENV{CFLAGS} "${orig_cflags}")
    endif()
  endif()
endfunction()
