# Every package in GITACHE_PACKAGES must have a config file.
set(GITACHE_CONFIGS_DIR "${CMAKE_SOURCE_DIR}/cmake/gitache-configs" CACHE PATH "Directory containing configs for gitache packages.")
message(STATUS "Reading package configurations from \"${GITACHE_CONFIGS_DIR}/\"...")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cwm4/cmake")

include(gitache_config)
include(ExternalProject)

# Create necessary directories.
set(_package_directory "${CMAKE_CURRENT_BINARY_DIR}/packages")
file(MAKE_DIRECTORY ${_package_directory})

# Generate a unique ID for file locking.
string(TIMESTAMP _current_time "%Y-%m-%dT%H:%M")
string(RANDOM LENGTH 8 _random_string)
set(gitache_package_lock_id "${CMAKE_SOURCE_DIR} - configured ${_current_time} - ${_random_string}")

function(lock_directory package_root)
  execute_process(
    COMMAND "${GITACHE_CORE_SOURCE_DIR}/lock.sh" ${package_root} ${gitache_package_lock_id}
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _exit_code
  )
  if (NOT ${_exit_code} EQUAL 0)
    message(FATAL_ERROR "Could not lock directory.")
  endif ()
endfunction()

function(unlock_directory package_root)
  execute_process(
    COMMAND "${GITACHE_CORE_SOURCE_DIR}/unlock.sh" ${package_root} ${gitache_package_lock_id}
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _exit_code
  )
  if (NOT ${_exit_code} EQUAL 0)
    message(FATAL_ERROR "Could not unlock directory.")
  endif ()
endfunction()

set(package_independent_seed ...)
foreach (gitache_package ${GITACHE_PACKAGES})
  if (NOT EXISTS "${GITACHE_CONFIGS_DIR}/${gitache_package}.cmake")
    message(FATAL_ERROR
      " No configuration file found for package ${gitache_package}.\n"
      " Please add a file \"${GITACHE_CONFIGS_DIR}/${gitache_package}.cmake\"."
    )
  endif ()
  # Load the user specified configuration for this package.
  include("${GITACHE_CONFIGS_DIR}/${gitache_package}.cmake")
  # Generate an external project.
  set(_output_file "${_package_directory}/${gitache_package}.cmake")
  # Calculate a hash that determines everything that might have an influence on the build result.
  string(SHA256 ${gitache_package}_config_hash "${package_independent_seed} ${external_project_arguments} ${cmake_arguments}")

  Dout("${gitache_package}_config_hash = \"${${gitache_package}_config_hash}\"")
  Dout("${gitache_package}: external_project_arguments = \"${external_project_arguments}\".")
  Dout("${gitache_package}: cmake_arguments = \"${cmake_arguments}\".")

  set(_package_root "${GITACHE_ROOT}/${gitache_package}")
  set(_package_install_dir "${_package_root}/${${gitache_package}_config_hash}")

  set(gitache_package_PREFIX "${_package_root}")
  set(gitache_package_INSTALL_DIR "${_package_install_dir}")
  set(gitache_package_CMAKE_ARGS "${cmake_arguments} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")
  set(gitache_package_lock_COMMAND "${GITACHE_CORE_SOURCE_DIR}/lock.sh ${_package_root} \"${gitache_package_lock_id}\"")
  set(gitache_package_unlock_COMMAND "${GITACHE_CORE_SOURCE_DIR}/unlock.sh ${_package_root} \"${gitache_package_lock_id}\"")
  configure_file("${CMAKE_CURRENT_LIST_DIR}/package.cmake.in" ${_output_file} @ONLY)
  file(MAKE_DIRECTORY ${_package_root})
  lock_directory(${_package_root})
  Dout("Processing generated configuration file \"${_output_file}\".")
  include("${_output_file}")
  unlock_directory(${_package_root})

  # The find_package will be done in the parent scope.
  set(${gitache_package}_ROOT "${_package_install_dir}" PARENT_SCOPE)
  # Also set this variable in the current scope, so that subsequent packages can find packages we already configured.
  set(${gitache_package}_ROOT "${_package_install_dir}")
  Dout("${gitache_package}: ${gitache_package}_ROOT = \"${_package_install_dir}\".")

endforeach ()
