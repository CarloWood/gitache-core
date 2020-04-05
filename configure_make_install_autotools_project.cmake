# The following variables need to be defined before including this file:
#
# SOURCE_DIR                    - The source directory of the package.
# BINARY_DIR                    - The binary directory of the package.
# INSTALL_PREFIX                - The prefix used for installation of the package.
# CMAKE_MESSAGE_LOG_LEVEL       - An optional log-level for the cmake child processes.
# GITACHE_CORE_SOURCE_DIR       - The directory containing gitache-core.

list(PREPEND CMAKE_MODULE_PATH "${GITACHE_CORE_SOURCE_DIR}/utils")
include(debug_support)  # For Dout.
include(ProcessorCount)

#include(${CMAKE_SOURCE_DIR}/../cwm4/cmake/dump_cmake_variables.cmake)
#dump_cmake_variables(.* RelWith)

# Process log-level, again.
set(_where NONE)
if (DEFINED CACHE{CMAKE_MESSAGE_LOG_LEVEL})
  message(STATUS "CMAKE_MESSAGE_LOG_LEVEL = \"${CMAKE_MESSAGE_LOG_LEVEL}\".")
  if(${CMAKE_MESSAGE_LOG_LEVEL} STREQUAL "DEBUG")
    set(_where "STDOUT")
  endif()
endif ()

# Determine the number of cores we have, again.
ProcessorCount(_cpus)
if(_cpus EQUAL 0)
  set(_cpus 4)
endif()

# Bootstrap step.
execute_process(
  COMMAND
    autoreconf -if
  COMMAND_ECHO ${_where}
  WORKING_DIRECTORY ${SOURCE_DIR}
  RESULT_VARIABLE _result_error
)

if(_result_error)
  message(FATAL_ERROR "Failed to bootstrap autotools project at \"${SOURCE_DIR}\".")
endif()

# Configure step.
execute_process(
  COMMAND
    ${SOURCE_DIR}/configure --prefix=${INSTALL_PREFIX}
  COMMAND_ECHO ${_where}
  WORKING_DIRECTORY ${BINARY_DIR}
  RESULT_VARIABLE _result_error
)

if(_result_error)
  message(FATAL_ERROR "Failed to configure autotools project at \"${SOURCE_DIR}\".")
endif()

# Build step.
execute_process(
  COMMAND
    make -j ${_cpus}
  COMMAND_ECHO ${_where}
  WORKING_DIRECTORY ${BINARY_DIR}
  RESULT_VARIABLE _result_error
)

if(_result_error)
  message(FATAL_ERROR "Failed to make autotools project at \"${BINARY_DIR}\".")
endif()

# Install step.
execute_process(
  COMMAND
    make install
  COMMAND_ECHO ${_where}
  WORKING_DIRECTORY ${BINARY_DIR}
  RESULT_VARIABLE _result_error
)

if(_result_error)
  message(FATAL_ERROR "Failed to install autotools project at \"${BINARY_DIR}\".")
endif()