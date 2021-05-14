# -*- cmake -*-
# Copyright (C) Dmitry Igrishin

project(sqlite3)
cmake_minimum_required(VERSION 3.16)

set(SQLITE_SHELL On CACHE BOOL
  "Build SQLite shell?")

set(sqlite3_headers sqlite3.h sqlite3ext.h)

add_library(sqlite3 STATIC ${sqlite3_headers} sqlite3.c)
if (UNIX)
  target_link_libraries(sqlite3 pthread)
endif()
target_include_directories(sqlite3 PUBLIC include)
target_compile_definitions(sqlite3 PUBLIC
  SQLITE_OMIT_DEPRECATED
  SQLITE_OMIT_LOAD_EXTENSION)
list(APPEND targets sqlite3)

if(SQLITE_SHELL)
  add_executable(sqlite3shell shell.c)
  target_link_libraries(sqlite3shell sqlite3)
  list(APPEND targets sqlite3shell)
endif()

install(TARGETS ${targets}
  ARCHIVE  DESTINATION ${CMAKE_INSTALL_PREFIX}
  LIBRARY  DESTINATION ${CMAKE_INSTALL_PREFIX}
  RUNTIME  DESTINATION ${CMAKE_INSTALL_PREFIX})

install(FILES ${sqlite3_headers}
  DESTINATION ${CMAKE_INSTALL_PREFIX})
