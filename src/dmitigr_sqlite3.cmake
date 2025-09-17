# -*- cmake -*-
# Copyright (C) Dmitry Igrishin

project(sqlite3)
cmake_minimum_required(VERSION 3.16)

set(SQLITE3_SHELL On CACHE BOOL
  "Build SQLite shell?")

set(SQLITE3_INSTALL On CACHE BOOL
  "Install SQLite?")

set(sqlite3_headers sqlite3.h sqlite3ext.h)

add_library(sqlite3 STATIC ${sqlite3_headers} sqlite3.c)
if (UNIX)
  target_link_libraries(sqlite3 pthread)
endif()
if(SQLITE3_INSTALL)
  target_include_directories(sqlite3 PUBLIC include)
else()
  target_include_directories(sqlite3 PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
endif()
target_compile_definitions(sqlite3 PUBLIC
  SQLITE_OMIT_DEPRECATED
  SQLITE_OMIT_LOAD_EXTENSION)
list(APPEND targets sqlite3)

if(SQLITE3_SHELL)
  add_executable(sqlite3shell shell.c)
  target_link_libraries(sqlite3shell sqlite3)
  list(APPEND targets sqlite3shell)
endif()

if(SQLITE3_INSTALL)
  install(TARGETS ${targets}
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin)

  install(FILES ${sqlite3_headers} DESTINATION include)
endif()
