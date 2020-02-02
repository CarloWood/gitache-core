# Our first task is to make sure that GITACHE_CORE_SHA1 is checked out.
# This is done by executing git commands directly; so find git.

# This is the gitache-core git repository.
set(GITACHE_CORE_SOURCE_DIR "${GITACHE_CORE_DIR}/source")
list(APPEND CMAKE_MODULE_PATH "${GITACHE_CORE_SOURCE_DIR}/hutils")
include(gitache_get_git_executable)
gitache_get_git_executable(git_executable)
message(DEBUG "git_executable = \"${git_executable}\".")

# Check if the needed sha1 is in our local repository.

# Get the SHA1 that is checkout out right now.
execute_process(COMMAND ${git_executable} rev-parse HEAD
  WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
  OUTPUT_VARIABLE head_sha1
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if (NOT head_sha1 STREQUAL GITACHE_CORE_SHA1)
  set(GITACHE_CORE_SHA1 "abcdef")
  # If the right SHA1 is not already checked out,
  message(DEBUG "head_sha1 = \"${head_sha1}\", GITACHE_CORE_SHA1 = \"${GITACHE_CORE_SHA1}\".")
  # check if the SHA1 is in the local repository.
  execute_process(COMMAND ${git_executable} cat-file -e "${GITACHE_CORE_SHA1}^{commit}"
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _result_error
  )
#    OUTPUT_QUIET
#    ERROR_QUIET
  if (_result_error EQUAL "0")
    message(STATUS "SUCCESS: _result_error = \"${_result_error}\".")
  else ()
    message(STATUS "ERROR: _result_error = \"${_result_error}\".")
  endif ()
else ()
  message(STATUS "Already equal!")
endif ()
