#
# Wrapper around add_subdirectory to only add non-empty subdirectory.
#
macro(add_subdirectory_if_not_empty a_subdir)
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${a_subdir}/CMakeLists.txt")
    message(STATUS "Add subdirectory ${a_subdir}")
    add_subdirectory(${a_subdir})
  else()
    message(
      WARNING
        "Subdirectory ${a_subdir} seems empty (no CMakeLists.txt).\nMake sure to have all git submodules populated and have read access to it.\nIf you don't have read access, you can ignore this message."
    )
  endif()
endmacro()
