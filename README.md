## Gitache developers

If you want to experiment with making changes to gitache itself,
and want to support both (a gitache submodule being present, or not) you
can use the first version given under `Basic usage` (see https://github.com/CarloWood/gitache)
but add the following immediately after the `include(FetchContent)` line:

    # If a local gitache submodule is present then use that rather than downloading one.  
    if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/gitache/.git)  
      # This will disable the use of the GIT_REPOSITORY/GIT_TAG below, and disable the  
      # FetchContent- download and update step. Instead, use the gitache submodule as-is.  
      set(FETCHCONTENT_SOURCE_DIR_GITACHE "gitache" CACHE INTERNAL "" FORCE)  
    endif ()

This more verbose version allows you to clone gitache in the root
of your project, without adding it to the project as a submodule, and
make changes to it as you see fit, to experiment, while users of the
project don't need a local gitache directory.

Cloning a local gitache-core in the root of the project is supported
by default. This too will disable any downloading of gitache-core and
use the local gitache-core directory as-is.
