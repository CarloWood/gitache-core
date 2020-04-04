# Copyright (c) 2020, Carlo Wood (carlo@alinoe.com)
# All rights reserved.

# This module makes sure the gitache-core source with sha1
# of ${GITACHE_CORE_SHA1} is available.
#
# Input:
#    gitache_core_is_local              True if this is a local submodule.
#    GITACHE_CORE_SHA1                  The SHA1 of the required commit of gitache-core.
#
# Output:
#    CMAKE_MODULE_PATH                  This file prepends the necessary module load paths.
#    git_executable                     Set to the absolute path to the git executable.
#    gitache_need_include               If GITACHE_CORE_SHA1 wasn't checked out yet, then
#                                       if gitache_core_is_local is FALSE, this file will
#                                       do the (fetch and) checkout and set
#                                       gitache_need_include to TRUE. Then return to reload.
#                                       Otherwise, when gitache_core_is_local is TRUE, that
#                                       is an error.
#
# If GITACHE_CORE_SHA1 is already checked out, then GITACHE_CORE_SOURCE_DIR
# is locked and control passed to main.cmake.

# Make sure that GITACHE_CORE_SHA1 is checked out.
# This is done by executing git commands directly; so find git.

# Add utils subdirectory to CMAKE_MODULE_PATH.
list(PREPEND CMAKE_MODULE_PATH "${GITACHE_CORE_SOURCE_DIR}/utils")

# Include utility modules and find git executable.
include(gitache_get_git_executable)
include(debug_support)
gitache_get_git_executable(git_executable)
Dout("git_executable = \"${git_executable}\".")

# Stop other processes from changing the SHA1.
lock_core_directory()

# Get the SHA1 that is checked out right now.
execute_process(COMMAND ${git_executable} rev-parse HEAD
  WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
  OUTPUT_VARIABLE head_sha1
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
# If the right SHA1 is not already checked out,
if (NOT head_sha1 STREQUAL GITACHE_CORE_SHA1)
  Dout("head_sha1 = \"${head_sha1}\", GITACHE_CORE_SHA1 = \"${GITACHE_CORE_SHA1}\".")
  if (gitache_core_is_local)
    if (GITACHE_CORE_SHA1 STREQUAL "")
      set(_fatal_message "Local ${PROJECT_NAME} detected.")
    else ()
      set(_fatal_message "The local submodule has checked out ${head_sha1}, but ${GITACHE_CORE_SHA1} is requested.")
    endif ()
    message(FATAL_ERROR
      " ${_fatal_message} Please set the environment variable GITACHE_CORE_SHA1 to the sha1 that is checked out before calling cmake:\n"
      " \n     export GITACHE_CORE_SHA1=$(git -C ${GITACHE_CORE_SOURCE_DIR} rev-parse HEAD)\n")
  endif ()
  # check if the SHA1 is in the local repository.
  execute_process(COMMAND ${git_executable} cat-file -e "${GITACHE_CORE_SHA1}^{commit}"
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _result_error
    ERROR_QUIET
  )
  if (NOT _result_error EQUAL 0)
    # That SHA1 is not known yet. Fetch it from upstream.
    execute_process(COMMAND ${git_executable} fetch
      WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    )
  endif ()
  set(gitache_need_include TRUE)
  # Now checkout the needed SHA1.
  execute_process(COMMAND ${git_executable} checkout ${GITACHE_CORE_SHA1}
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _result_error
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if (_result_error)
    message(FATAL_ERROR " Failed to checkout ${GITACHE_CORE_SHA1} of gitache-core!")
  endif ()
  # This file was changed. Reload it!
  unlock_core_directory()
  return()
else ()
  message(STATUS "Gitache-core is already at ${GITACHE_CORE_SHA1}.")
endif ()

# Now, with ${GITACHE_CORE_SOURCE_DIR} process locked, start the real thing.
list(PREPEND CMAKE_MODULE_PATH "${GITACHE_CORE_SOURCE_DIR}")
set(ERROR_MESSAGE False)
include(main)

# We're finished with gitache-core.
unlock_core_directory()

if(ERROR_MESSAGE)
  # This happens when ERROR_MESSAGE was set in package.cmake.
  message(FATAL_ERROR ${ERROR_MESSAGE})
endif()
