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

# @brief Adds SQLite 3 with add_library() to the project.
#
# @details The output of this macro depends on the following variables:
#   - `SQLITE3_SHELL` - Boolean which indicates the request to build SQLite
#   shell;
#   - `SQLITE3_INSTALL` - Boolean which indicates the request to install.
#
# @param sqlite3_src_root A path where to look for SQLite sources.
macro(dmitigr_add_sqlite3 sqlite3_src_root)
  set(dmitigr_sqlite3_headers
    ${sqlite3_src_root}/sqlite3.h
    ${sqlite3_src_root}/sqlite3ext.h)

  add_library(sqlite3 STATIC
    ${dmitigr_sqlite3_headers}
    ${sqlite3_src_root}/sqlite3.c)

  if(UNIX)
    target_link_libraries(sqlite3 pthread)
  endif()
  if(SQLITE3_INSTALL)
    target_include_directories(sqlite3 PUBLIC include)
  else()
    target_include_directories(sqlite3 PUBLIC ${sqlite3_src_root})
  endif()
  target_compile_definitions(sqlite3 PUBLIC
    SQLITE_OMIT_DEPRECATED
    SQLITE_OMIT_LOAD_EXTENSION)
  list(APPEND targets sqlite3)

  if(SQLITE3_SHELL)
    add_executable(sqlite3shell ${sqlite3_src_root}/shell.c)
    target_link_libraries(sqlite3shell sqlite3)
    list(APPEND targets sqlite3shell)
  endif()

  if(SQLITE3_INSTALL)
    install(TARGETS ${targets}
      ARCHIVE DESTINATION lib
      LIBRARY DESTINATION lib
      RUNTIME DESTINATION bin)

    install(FILES ${dmitigr_sqlite3_headers} DESTINATION include)
  endif()

  unset(dmitigr_sqlite3_headers)
endmacro()
