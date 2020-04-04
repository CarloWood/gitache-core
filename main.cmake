# Every package in GITACHE_PACKAGES must have a config file.
set(GITACHE_CONFIGS_DIR "${CMAKE_SOURCE_DIR}/cmake/gitache-configs" CACHE PATH "Directory containing configs for gitache packages.")
message(STATUS "Reading package configurations from \"${GITACHE_CONFIGS_DIR}/\"...")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cwm4/cmake")

include(gitache_config)
include(ExternalProject)
include(gitache_create_step)

# Create necessary directories.
set(_package_directory "${CMAKE_CURRENT_BINARY_DIR}/packages")
file(MAKE_DIRECTORY ${_package_directory})

# Generate a unique ID for file locking.
string(TIMESTAMP _current_time "%Y-%m-%dT%H:%M")
string(RANDOM LENGTH 8 _random_string)
set(gitache_package_LOCK_ID "${CMAKE_SOURCE_DIR} - configured ${_current_time} - ${_random_string}")

function(lock_directory package_root)
  execute_process(
    COMMAND "${GITACHE_CORE_SOURCE_DIR}/lock.sh" ${package_root} ${gitache_package_LOCK_ID}
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _exit_code
  )
  if (NOT ${_exit_code} EQUAL 0)
    message(FATAL_ERROR "Could not lock directory.")
  endif ()
endfunction()

function(unlock_directory package_root)
  execute_process(
    COMMAND "${GITACHE_CORE_SOURCE_DIR}/unlock.sh" ${package_root} ${gitache_package_LOCK_ID}
    WORKING_DIRECTORY ${GITACHE_CORE_SOURCE_DIR}
    RESULT_VARIABLE _exit_code
  )
  if (NOT ${_exit_code} EQUAL 0)
    message(FATAL_ERROR "Could not unlock directory.")
  endif ()
endfunction()

message(STATUS "CMAKE_MESSAGE_LOG_LEVEL = \"${CMAKE_MESSAGE_LOG_LEVEL}\".")
set(gitache_log_level)
if (DEFINED CACHE{CMAKE_MESSAGE_LOG_LEVEL})
  set(gitache_log_level "-DCMAKE_MESSAGE_LOG_LEVEL=${CMAKE_MESSAGE_LOG_LEVEL}")
endif ()

set(package_independent_seed "${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
foreach (gitache_package ${GITACHE_PACKAGES})
  if (NOT EXISTS "${GITACHE_CONFIGS_DIR}/${gitache_package}.cmake")
    message(FATAL_ERROR
      " No configuration file found for package ${gitache_package}.\n"
      " Please add a file \"${GITACHE_CONFIGS_DIR}/${gitache_package}.cmake\"."
    )
  endif ()
  # Load the user specified configuration for this package.
  set(GIT_TAG)
  set(gitache_package_CMAKE_CONFIG "Release")
  include("${GITACHE_CONFIGS_DIR}/${gitache_package}.cmake") # Sets GIT_TAG if any is specified.
  # Generate an external project.
  #set(_output_file "${_package_directory}/${gitache_package}.cmake")
  # Calculate a hash that determines everything that might have an influence on the build result.
  string(SHA256 ${gitache_package}_config_hash "${package_independent_seed} ${arguments_to_FetchContent_Declare} ${cmake_arguments}")

  Dout("${gitache_package}_config_hash = \"${${gitache_package}_config_hash}\"")
  Dout("${gitache_package}: arguments_to_FetchContent_Declare = \"${arguments_to_FetchContent_Declare}\".")
  Dout("${gitache_package}: cmake_arguments = \"${cmake_arguments}\".")

  set(gitache_package_ROOT "${GITACHE_ROOT}/${gitache_package}")
  set(gitache_package_NAME "gitache_package_${gitache_package}")
  set(gitache_package_INSTALL_PREFIX "${gitache_package_ROOT}/${${gitache_package}_config_hash}")
  set(gitache_package_CMAKE_ARGS "${cmake_arguments} -DCMAKE_INSTALL_PREFIX=${gitache_package_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=${gitache_package_CMAKE_CONFIG}")

  set(_gitupdate_stamp_file "${gitache_package_ROOT}/src/gitache_package_${gitache_package}-stamp/gitache_package_${gitache_package}-gitupdate")
  set(_lock_stamp_file "${gitache_package_ROOT}/src/gitache_package_${gitache_package}-stamp/gitache_package_${gitache_package}-lock")

  set(gitache_package_update_COMMAND)
  string(CONCAT gitache_package_update_COMMAND
      "${CMAKE_COMMAND} "
          "${gitache_log_level} "
          "-DGIT_EXE='${git_executable}' "
          "-DGIT_TAG=${GIT_TAG} "
          "-DPACKAGE_ROOT='${gitache_package_ROOT}' "
          "-DPACKAGE_NAME=${gitache_package} "
          "-DSTAMP_FILE='${_gitupdate_stamp_file}' "
          "-P ${GITACHE_CORE_SOURCE_DIR}/package-gitupdate.cmake")
  set(gitache_package_lock_COMMAND)
  string(CONCAT gitache_package_lock_COMMAND
      "${CMAKE_COMMAND} "
      "${gitache_log_level} "
      "-DLOCK_SCRIPT='${GITACHE_CORE_SOURCE_DIR}/lock.sh' "
      "-DPACKAGE_ROOT='${gitache_package_ROOT}' "
      "-DLOCK_ID='${gitache_package_LOCK_ID}' "
      "-DSTAMP_FILE='${_lock_stamp_file}' "
      "-P ${GITACHE_CORE_SOURCE_DIR}/package-lock.cmake")
  set(gitache_package_unlock_COMMAND "${GITACHE_CORE_SOURCE_DIR}/unlock.sh ${gitache_package_ROOT} \"${gitache_package_LOCK_ID}\"")
  #  configure_file("${CMAKE_CURRENT_LIST_DIR}/package.cmake.in" ${_output_file} @ONLY)
  file(MAKE_DIRECTORY ${gitache_package_ROOT})
  lock_directory(${gitache_package_ROOT})
  include("${CMAKE_CURRENT_LIST_DIR}/package.cmake")
  unlock_directory(${gitache_package_ROOT})

  if(ERROR_MESSAGE)
    break()
  endif()

  # The find_package will be done in the parent scope.
  set(${gitache_package}_ROOT "${gitache_package_INSTALL_PREFIX}" PARENT_SCOPE)
  # Also set this variable in the current scope, so that subsequent packages can find packages we already configured.
  set(${gitache_package}_ROOT "${gitache_package_INSTALL_PREFIX}")
  Dout("${gitache_package}: ${gitache_package}_ROOT = \"${${gitache_package}_ROOT}\".")

endforeach ()
