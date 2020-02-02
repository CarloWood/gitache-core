# Copyright (c) 2013, Ruslan Baratov
# All rights reserved.

function(gitache_status_debug)
  if(GITACHE_STATUS_DEBUG)
    string(TIMESTAMP timestamp)
    if(GITACHE_CACHE_RUN)
      set(type "DEBUG (CACHE RUN)")
    else()
      set(type "DEBUG")
    endif()
    message(STATUS "[gitache *** ${type} *** ${timestamp}] ${ARGV}")
  endif()
endfunction()
