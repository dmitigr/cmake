# -*- cmake -*-
# Copyright (C) Dmitry Igrishin

project(libev)
cmake_minimum_required(VERSION 3.16)

set(ev_headers ev.h ev++.h event.h)
set(ev_implementations ev.c event.c)

add_library(ev STATIC ${ev_headers} ${ev_implementations})

install(TARGETS ev
  ARCHIVE  DESTINATION ${CMAKE_INSTALL_PREFIX}
  LIBRARY  DESTINATION ${CMAKE_INSTALL_PREFIX}
  RUNTIME  DESTINATION ${CMAKE_INSTALL_PREFIX})

install(FILES ${libev_headers}
  DESTINATION ${CMAKE_INSTALL_PREFIX})
