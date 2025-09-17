# -*- cmake -*-
# Copyright (C) Dmitry Igrishin

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
