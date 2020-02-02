# Copyright (c) 2013, Ruslan Baratov
# All rights reserved.

include(gitache_internal_error)

function(gitache_assert_not_empty_string test_string)
  string(COMPARE EQUAL "${test_string}" "" is_empty)
  if(is_empty)
    gitache_internal_error("Unexpected empty string")
  endif()
endfunction()
