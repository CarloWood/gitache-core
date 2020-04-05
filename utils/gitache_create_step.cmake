include_guard(DIRECTORY)

function(gitache_create_step step_name gitache_package)
  set(_package_root "${GITACHE_ROOT}/${gitache_package}")
  set(_stamp_dir "${_package_root}/src/gitache_package_${gitache_package}-stamp")

  set(zero ALWAYS SILENT)
  set(one COMMENT)
  set(multiple COMMAND)

  cmake_parse_arguments(PARSE_ARGV 2 "_step" "${zero}" "${one}" "${multiple}")

  if("${_step_COMMENT}" STREQUAL "")
    set(_step_COMMENT "Performing ${step_name} step for 'gitache_package_${gitache_package}'")
  endif()
  if(${_step_SILENT})
    set(_step_COMMENT)
  endif()

  set(_stamp_file "${_stamp_dir}/step_${gitache_package}-${step_name}")
  message(STATUS "_stamp_file = \"${_stamp_file}\".")
  set(_touch)
  if(${_step_ALWAYS})
    file(REMOVE ${_stamp_file})
  else()
    set(_touch ${CMAKE_COMMAND} -E touch ${_stamp_file})
  endif()

  add_custom_command(
    OUTPUT ${_stamp_file}
    COMMENT "${_step_COMMENT}"
    WORKING_DIRECTORY ${_package_root}
    COMMAND ${_step_COMMAND}
    COMMAND ${_touch}
    VERBATIM
  )
endfunction()
