# Our first task is to make sure that GITACHE_CORE_SHA1 is checked out.
# This is done by executing git commands directly, so find git.

include()

message(STATUS "We are here: ${CMAKE_CURRENT_LIST_FILE}; GITACHE_CORE_SHA1 = ${GITACHE_CORE_SHA1}")
