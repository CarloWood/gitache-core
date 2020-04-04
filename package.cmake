# The following variables need to be defined before including this file:
#
# gitache_package_NAME                  - The name of the package as used by FetchContent.
# gitache_package_ROOT                  - The '_deps' base directory that FetchContent should use.
# gitache_package_CMAKE_CONFIG          - The build config (for multi-target generators).
# gitache_package_CMAKE_ARGS            - If the package is a cmake project, arguments that should be passed to cmake during configuration.
#                                         This already includes -DCMAKE_BUILD_TYPE=${gitache_package_CMAKE_CONFIG}, for single-target.
# gitache_package_INSTALL_PREFIX        - The prefix used for installation of the package.
# arguments_to_FetchContent_Declare     - Space separated list of arguments that need to be passed to FetchContent_Declare.
# gitache_package_LOCK_ID               - An identifying string for this install (this is written to the DONE file).
# gitache_log_level                     - An optional -DCMAKE_MESSAGE_LOG_LEVEL=* argument for a cmake child process.
# GITACHE_CORE_SOURCE_DIR               - The directory containing gitache-core.

# This is an output variable.
set(ERROR_MESSAGE False)

# Use $GITACHE_ROOT/package_name as base dir (this replaces the usual ${CMAKE_CURRENT_BINARY_DIR}/_deps).
set(FETCHCONTENT_BASE_DIR "${gitache_package_ROOT}")

# Following how FetchContent works, the source code of a packages is put into
set(_source_dir ${FETCHCONTENT_BASE_DIR}/${gitache_package_NAME}-src)

# And the build directory then is prepared at
set(_build_dir ${FETCHCONTENT_BASE_DIR}/${gitache_package_NAME}-build)

# The existence of this file marks successful installation.
set(_done_file "${gitache_package_INSTALL_PREFIX}/DONE")

# We already have FETCHCONTENT_BASE_DIR locked before including this file.
# Hence if this file exists then we're done.
if(EXISTS ${_done_file})
  message(STATUS "${gitache_package_NAME} is already installed.")
else()
  set(FETCHCONTENT_QUIET OFF)

  Dout("Calling FetchContent_Declare(${gitache_package_NAME} ${arguments_to_FetchContent_Declare})")
  separate_arguments(_args UNIX_COMMAND ${arguments_to_FetchContent_Declare})
  FetchContent_Declare(
    ${gitache_package_NAME}
    # E.g. GIT_TAG and GIT_REPOSITORY. See gitache_config.cmake for a full list.
    ${_args}
  )

  string(TOLOWER ${gitache_package_NAME} gitache_package_NAME_lc)
  FetchContent_GetProperties(${gitache_package_NAME})
  if(NOT ${gitache_package_NAME_lc}_POPULATED)
    # Populate the source and binary directories of this package.
    FetchContent_Populate(${gitache_package_NAME})

    # Show the COMMAND if log-level is DEBUG.
    set(_where NONE)
    if(${CMAKE_MESSAGE_LOG_LEVEL} STREQUAL "DEBUG")
      set(_where "STDOUT")
    endif()

    if(EXISTS ${${gitache_package_NAME_lc}_SOURCE_DIR}/CMakeLists.txt)
      Dout("Attempting to configure/build/install \"${gitache_package_NAME}\" as cmake project; running:")
      # Start a separate process to configure, build and install this cmake package.
      execute_process(
        COMMAND
          ${CMAKE_COMMAND} ${gitache_log_level}
            -DCMAKE_ARGS=${gitache_package_CMAKE_ARGS}
            -DCMAKE_CONFIG=${gitache_package_CMAKE_CONFIG}
            -DGITACHE_CORE_SOURCE_DIR=${GITACHE_CORE_SOURCE_DIR}
            -DSOURCE_DIR=${${gitache_package_NAME_lc}_SOURCE_DIR}
            -DBINARY_DIR=${${gitache_package_NAME_lc}_BINARY_DIR}
            -DINSTALL_PREFIX=${gitache_package_INSTALL_PREFIX}
            -P "${CMAKE_CURRENT_LIST_DIR}/configure_build_install_cmake_project.cmake"
        COMMAND_ECHO ${_where}
        RESULT_VARIABLE
          _result_error
      )
      if(_result_error) # A cmake script always returns just 0 (success) or 1 (failure).
        set(ERROR_MESSAGE "Failed to config/build/install gitache package \"${gitache_package_NAME}\".")
      endif()
    endif()
  endif()

  if (NOT ERROR_MESSAGE)
    # The above only has to be done once.
    Dout("Creating ${_done_file}")
    file(WRITE ${_done_file} ${gitache_package_LOCK_ID})
  endif()

  set(FETCHCONTENT_QUIET ON)
endif()

# Restore default values.
unset(FETCHCONTENT_BASE_DIR)
