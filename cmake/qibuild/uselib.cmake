## Copyright (C) 2011 Aldebaran Robotics

#! qiBuild UseLib
# ===============
#
# == Overview ==
# qi_use_lib handles dependencies between projects.
# It will call find_package for you, then do all the include_directories
# and target_link_libraries that are needed.
#

if (_QI_USELIB_CMAKE_)
  return()
endif()
set(_QI_USELIB_CMAKE_ TRUE)


# Set CMAKE_FIND_LIBRARY_SUFFIXES so that
# only static libs are searched when ${pkg}_STATIC
# is set.
# The _backup argument will be set to the previous
# value of CMAKE_FIND_LIBRARY_SUFFIXES.
# Don't forget to call _qi_disable_check_for_static(_backup)
# afterwards !
function(_qi_check_for_static pkg _backup)
  set(${_backup} ${CMAKE_FIND_LIBRARY_SUFFIXES} PARENT_SCOPE)
  if(${pkg}_STATIC)
    if(UNIX)
      set(CMAKE_FIND_LIBRARY_SUFFIXES ".a" PARENT_SCOPE)
    endif()
  endif()
endfunction()

function(_qi_disable_check_for_static _backup)
  set(CMAKE_FIND_LIBRARY_SUFFIXES "${_backup}" PARENT_SCOPE)
endfunction()


#compute the dependencies list, removing duplicate
#TODO: store computed dependencies in ${_U_PKG}_FLAT_DEPENDS ?
function(_qi_use_lib_get_deps name _OUT_list)
  set(_result ${ARGN})
  list(LENGTH _result _count)
  if (_count EQUAL 0)
    return()
  endif()

  string(TOUPPER ${name} _U_NAME)

  foreach(_pkg ${ARGN})
    string(TOUPPER ${_pkg} _U_PKG)
    # First, we search for *-config.cmake files
    # generated by qiBuild, then we look
    # for upstream Find-*.cmake
    # See: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:find_package
    if (NOT ${_U_PKG}_SEARCHED AND NOT ${_U_PKG}_PACKAGE_FOUND)

      _qi_check_for_static("${_pkg}" _backup_static)

      # find_package in two calls. The first call:
      # Uses NO_MODULE - looks for PKGConfig.cmake, not FindPKG.cmake
      # Uses QUIET     - no warning will be generated
      # If Config is found, then PKG_DIR will be set so that the following
      # find_package knows where to look
      find_package(${_pkg} NO_MODULE QUIET)
      # _PACKAGE_FOUND is only set when using qibuild/cmake modules,
      # see comments in find.cmake for details.
      if(NOT ${_U_PKG}_PACKAGE_FOUND)
        find_package(${_pkg} QUIET REQUIRED)
      endif()

      _qi_disable_check_for_static("${_backup_static}")

      qi_set_global("${_U_PKG}_SEARCHED" TRUE)
    endif()

    foreach(_sub_dep ${${_U_PKG}_DEPENDS})
      list(FIND _result ${_sub_dep} _is_present)
      string(TOUPPER ${_sub_dep} _u_sub_dep)
      if (_is_present EQUAL -1)
        if (NOT ${_u_sub_dep}_FAT_DEPENDS)
          _qi_use_lib_get_deps("${_U_PKG}" _new_deps "${_sub_dep}")
        else()
          set(_new_deps ${${_u_sub_dep}_FAT_DEPENDS})
        endif()
        list(APPEND _result ${_new_deps})
      endif()
    endforeach()
  endforeach()

  #We remove duplicate here..
  #Problem: If libA and libB each depends on libC, we will have "A C B C".
  # libC need to be after libA and libB, so we need to take each libC occurence into acount,
  # in fact, we could optimise if we want and only take the last one,
  # but REMOVE_DUPLICATES keep the first occurence
  # so ... we reverse the list, remove duplicate and reverse again!
  list(REVERSE _result)
  list(REMOVE_DUPLICATES _result)
  list(REVERSE _result)

  #why? because it will avoid many recursion. we store the complete dependencies of a project
  # in cache, and use that, instead of digging into deps by recursion.
  qi_set_cache(${_U_NAME}_FAT_DEPENDS "${_result}")
  set(${_OUT_list} ${_result} PARENT_SCOPE)
endfunction()


#!
# Find dependencies and add them to the target <name>.
# This will call include_directories with XXX_INCLUDE_DIRS or fallback to XXX_INCLUDE_DIR.
# This will call target_link_libraries with XXX_LIBRARIES or fallback to XXX_LIBRARY.
# All dependencies should be found, otherwize it will fail. If you want to check if a
# package could be found, prefer using find_package.
#
# to search for static libs set XXX_STATIC=ON before calling qi_use_lib.
#
# \arg:name The target to add dependencies to
# \group:DEPENDENCIES The list of dependencies
function(qi_use_lib name)
  _qi_check_is_target("${name}")
  cmake_parse_arguments(ARG "" "PLATEFORM" "DEPENDS" ${ARGN})

  set(ARG_DEPENDS ${ARG_UNPARSED_ARGUMENTS} ${ARG_DEPENDS})

  _qi_use_lib_get_deps("${name}" _DEPS ${ARG_DEPENDS})

  foreach(_pkg ${_DEPS})
    string(TOUPPER ${_pkg} _U_PKG)

    if (DEFINED ${_U_PKG}_INCLUDE_DIRS)
      include_directories(${${_U_PKG}_INCLUDE_DIRS})
    elseif(DEFINED ${_U_PKG}_INCLUDE_DIR)
      include_directories(${${_U_PKG}_INCLUDE_DIR})
    endif()

    if (DEFINED ${_U_PKG}_LIBRARIES)
      target_link_libraries("${name}" ${${_U_PKG}_LIBRARIES})
    elseif (DEFINED ${_U_PKG}_LIBRARY)
      target_link_libraries("${name}" ${${_U_PKG}_LIBRARY})
    endif()

    # local lib are staged with _U_PKG_TARGET = localtargetname, this allow dependencies
    # between local libs
    if ( (DEFINED "${_U_PKG}_TARGET") AND (TARGET "${${_U_PKG}_TARGET}") )
      add_dependencies(${name} "${${_U_PKG}_TARGET}")
    endif()
    if(${_U_PKG}_DEFINITIONS)
      # Append the correct compile definitions to the target
      set(_to_add)
      get_target_property(_compile_defs ${name} COMPILE_DEFINITIONS)
      if(_compile_defs)
        set(_to_add ${_compile_defs})
      endif()
      list(APPEND _to_add "${${_U_PKG}_DEFINITIONS}")
      if(_to_add)
        set_target_properties(${name}
          PROPERTIES
            COMPILE_DEFINITIONS "${_to_add}")
      endif()
    endif()
  endforeach()
  string(TOUPPER "${name}" _U_name)
  qi_set_global("${_U_name}_DEPENDS" ${${_U_name}_DEPENDS} ${_DEPS})
endfunction()
