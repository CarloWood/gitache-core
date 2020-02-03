# Our first task is to make sure that GITACHE_CORE_SHA1 is checked out.
# This is done by executing git commands directly; so find git.

# This is the gitache-core git repository.
set(GITACHE_CORE_SOURCE_DIR "${GITACHE_CORE_DIR}/source")
list(APPEND CMAKE_MODULE_PATH "${GITACHE_CORE_SOURCE_DIR}/hutils")
include(gitache_get_git_executable)
gitache_get_git_executable(git_executable)
message(DEBUG "git_executable = \"${git_executable}\".")

# Check if the needed sha1 is in our local repository.

# Stop other processes from changing the SHA1.
message(STATUS "Locking \"${GITACHE_CORE_SOURCE_DIR}\"...")
file(LOCK ${GITACHE_CORE_SOURCE_DIR} DIRECTORY
  GUARD PROCESS
  RESULT_VARIABLE _error_result
  TIMEOUT 10
)
if (_error_result)
  message(FATAL_ERROR "  ${_error_result}.")
endif ()

# Get the SHA1 that is checked out right now.
execute_process(COMMAND ${git_executable} rev-parse HEAD
  WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
  OUTPUT_VARIABLE head_sha1
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
# If the right SHA1 is not already checked out,
if (NOT head_sha1 STREQUAL GITACHE_CORE_SHA1)
  message(DEBUG "head_sha1 = \"${head_sha1}\", GITACHE_CORE_SHA1 = \"${GITACHE_CORE_SHA1}\".")
  # check if the SHA1 is in the local repository.
  execute_process(COMMAND ${git_executable} cat-file -e "${GITACHE_CORE_SHA1}^{commit}"
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _result_error
    ERROR_QUIET
  )
  if (NOT _result_error EQUAL "0")
    # That SHA1 is not known yet. Fetch it from upstream.
    execute_process(COMMAND ${git_executable} fetch
      WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    )
  endif ()
  # Now checkout the needed SHA1.
  execute_process(COMMAND ${git_executable} checkout ${GITACHE_CORE_SHA1}
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _result_error
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if (_result_error)
    message(FATAL_ERROR "Failed to checkout ${GITACHE_CORE_SHA1} of gitache-core!")
  endif ()
else ()
  message(STATUS "Gitache-core is already at ${GITACHE_CORE_SHA1}.")
endif ()

message(STATUS "1. THIS IS THE LATEST VERSIONS!")
