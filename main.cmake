# Our first task is to make sure that GITACHE_CORE_SHA1 is checked out.
# This is done by executing git commands directly, so find git.

set(GITACHE_CORE_SOURCE_DIR "${GITACHE_CORE_DIR}/source")
list(APPEND CMAKE_PREFIX_PATH "${GITACHE_CORE_SOURCE_DIR}/hutils")
message(STATUS "CMAKE_PREFIX_PATH = \"${CMAKE_PREFIX_PATH}\".")
include(gitache_get_git_executable)

gitache_get_git_executable(git_executable)
message(STATUS "git_executable = \"${git_executable}\".")
