string(ASCII 127 _high_char)
set(_fake_escaped_semicolon ":${_high_char}${_high_char}${_high_char}")

function(gitache_config)
  set(one GIT_TAG GIT_REPOSITORY GIT_REMOTE_NAME GIT_SHALLOW GIT_PROGRESS)
  set(multiple GIT_SUBMODULES GIT_CONFIG CONFIGURE_ARGS CMAKE_ARGS BOOTSTRAP_COMMAND)

  cmake_parse_arguments(PARSE_ARGV 0 ${gitache_package} "" "${one}" "${multiple}")

  set(arguments_to_FetchContent_Declare)
  foreach (_arg ${one})
    set(_variable_name ${gitache_package}_${_arg})
    if("${${_variable_name}}" STREQUAL "")
      continue()
    endif()
    if("${_arg}" STREQUAL "GIT_TAG")
      set(GIT_TAG "${${_variable_name}}" PARENT_SCOPE)
    endif()
    if(arguments_to_FetchContent_Declare)
      string(APPEND arguments_to_FetchContent_Declare " ")
    endif()
    string(APPEND arguments_to_FetchContent_Declare ${_arg} " " "\"${${_variable_name}}\"")
  endforeach ()
  set(bootstrap_command)
  set(cmake_arguments)
  set(configure_arguments)
  foreach (_arg ${multiple})
    set(_variable_name ${gitache_package}_${_arg})
    if("${${_variable_name}}" STREQUAL "")
      continue()
    endif()
    string(REGEX MATCHALL "[^ ]+" _multiple_args_list "${${_variable_name}}")
    # Workaround for bug in list(SORT).
    string(REPLACE "\\;" ${_fake_escaped_semicolon} _escaped_list "${_multiple_args_list}")
    list(SORT _escaped_list)
    string(REPLACE "${_fake_escaped_semicolon}" "\\;" _sorted_list "${_escaped_list}")
    list(JOIN _sorted_list " " _sorted_arguments)
    if(_arg STREQUAL BOOTSTRAP_COMMAND)
      set(bootstrap_command ${_multiple_args_list})
    elseif(_arg STREQUAL CMAKE_ARGS)
      set(cmake_arguments ${_sorted_arguments})
    elseif(_arg STREQUAL CONFIGURE_ARGS)
      set(configure_arguments ${_multiple_args_list})
    else()
      if(arguments_to_FetchContent_Declare)
        string(APPEND arguments_to_FetchContent_Declare " ")
      endif()
      string(APPEND arguments_to_FetchContent_Declare ${_arg} " " "${_sorted_arguments}")
    endif()
  endforeach ()
  set(arguments_to_FetchContent_Declare ${arguments_to_FetchContent_Declare} PARENT_SCOPE)
  set(bootstrap_command ${bootstrap_command} PARENT_SCOPE)
  set(cmake_arguments ${cmake_arguments} PARENT_SCOPE)
  set(configure_arguments ${configure_arguments} PARENT_SCOPE)
endfunction()
