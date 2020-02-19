# Every package in GITACHE_PACKAGES must have a config file.
set(GITACHE_CONFIGS_DIR "${CMAKE_SOURCE_DIR}/gitache/configs")
message(STATUS "Reading package configurations from \"${GITACHE_CONFIGS_DIR}\"...")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cwm4/cmake")

include(gitache_config)
include(ExternalProject)

# Create necessary directories.
set(_package_directory "${CMAKE_CURRENT_BINARY_DIR}/packages")
file(MAKE_DIRECTORY ${_package_directory})

function(lock_directory)

endfunction()

function(unlock_directory)
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
  message(DEBUG ${_output_file})
  # Calculate a hash that determines everything that might have an influence on the build result.
  string(SHA256 ${gitache_package}_config_hash "${package_independent_seed} ${external_project_arguments} ${cmake_arguments}")

  message(DEBUG "${gitache_package}_config_hash = \"${${gitache_package}_config_hash}\"")
  message(DEBUG "${gitache_package}: external_project_arguments = \"${external_project_arguments}\".")
  message(DEBUG "${gitache_package}: cmake_arguments = \"${cmake_arguments}\".")

  set(_package_root "${GITACHE_ROOT}/${gitache_package}")
  set(_package_install_dir "${_package_root}/${${gitache_package}_config_hash}")

  set(gitache_package_PREFIX "${_package_root}")
  set(gitache_package_INSTALL_DIR "${_package_install_dir}")
  set(gitache_package_CMAKE_ARGS "${cmake_arguments} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")
  set(gitache_package_lock_COMMAND "${GITACHE_CORE_SOURCE_DIR}/lock")
  configure_file("${CMAKE_CURRENT_LIST_DIR}/package.cmake.in" ${_output_file} @ONLY)
  lock_directory(${_package_root} 10)
  include("${_output_file}")
  unlock_directory(${_package_root})

endforeach ()
