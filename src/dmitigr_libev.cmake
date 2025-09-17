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

# @brief Adds libev with add_library() to the project.
#
# @details The output of this macro depends on the following variables:
#   - `LIBEV_INSTALL` - Boolean which indicates the request to install.
#
# @param libev_src_root A path where to look for libev sources.
macro(dmitigr_add_libev libev_src_root)
  set(dmitigr_ev_headers
    ${libev_src_root}/ev.h
    ${libev_src_root}/ev++.h
    ${libev_src_root}/event.h)
  set(dmitigr_ev_implementations
    ${libev_src_root}/ev.c
    ${libev_src_root}/event.c)

  add_library(ev STATIC
    ${dmitigr_ev_headers}
    ${dmitigr_ev_implementations})

  if(LIBEV_INSTALL)
    install(TARGETS ev
      ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}
      LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}
      RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})

    install(FILES ${dmitigr_ev_headers}
      DESTINATION ${CMAKE_INSTALL_PREFIX})
  endif()

  foreach(suff headers implementations)
    unset(dmitigr_ev_${suff})
  endforeach()
endmacro()
