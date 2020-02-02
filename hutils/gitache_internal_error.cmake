# Copyright (c) 2014, Ruslan Baratov
# All rights reserved.

#include(gitache_error_page)

function(gitache_internal_error)
  message("")
  foreach(print_message ${ARGV})
    message("[gitache ** INTERNAL **] ${print_message}")
  endforeach()
  message("[gitache ** INTERNAL **] [Directory:${CMAKE_CURRENT_LIST_DIR}]")
  message("")
  #gitache_error_page("error.internal")
endfunction()
