# Our first task is to make sure that GITACHE_CORE_SHA1 is checked out.
# This is done by executing git commands directly; so find git.

# This is the gitache-core git repository.
set(GITACHE_CORE_SOURCE_DIR "${GITACHE_CORE_DIR}/source")
list(APPEND CMAKE_MODULE_PATH "${GITACHE_CORE_SOURCE_DIR}/hutils")
include(gitache_get_git_executable)
gitache_get_git_executable(git_executable)
message(DEBUG "git_executable = \"${git_executable}\".")

# Check if the needed sha1 is in our local repository.
execute_process(COMMAND git rev-parse HEAD
  WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
  OUTPUT_VARIABLE head_sha1
)
message(STATUS "head_sha1 = \"${head_sha1}\".")
