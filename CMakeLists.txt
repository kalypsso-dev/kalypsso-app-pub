# set minimal version to the one requested by kokkos
cmake_minimum_required(VERSION 3.18)

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.13.0")
  message(STATUS "Setting policy CMP0076 to use new behavior")
  cmake_policy(SET CMP0076 NEW)
endif()

# CMake 3.24 and above prefers to set the timestamps of all extracted contents to the time of the
# extraction.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.24)
  cmake_policy(SET CMP0135 NEW)
endif()

set(KALYPSSO_APP_PUB_VERSION "0.0.0")

# deduce KALYPSSO_APP_PUB_SHORT_VERSION using regex
string(REGEX MATCH "^[0-9]+\.[0-9]+\.[0-9]+" KALYPSSO_APP_PUB_SHORT_VERSION
             ${KALYPSSO_APP_PUB_VERSION})
if("${KALYPSSO_APP_PUB_SHORT_VERSION}" STREQUAL "")
  message(
    FATAL_ERROR
      "Unable to compute short version from KALYPSSO_APP_PUB_VERSION=${KALYPSSO_APP_PUB_VERSION}")
endif()

project(
  kalypsso-app-pub
  VERSION ${KALYPSSO_APP_PUB_SHORT_VERSION}
  LANGUAGES C CXX Fortran)

# project_name in small caps
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_SC)

#
# default local cmake macro repository
#
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

#
# Prevent from build in source tree
#
include(cmake/prevent_build_in_source.cmake)
prevent_build_in_source()

#
# Init build type: Release, Debug, ... (default is Release)
#
include(cmake/initBuildType.cmake)

# always export compile commands database
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#
# kalypsso options
#
include(cmake/options.cmake)

# C++17 is required for Kokkos >= 4.0 CMAKE_CXX_STANDARD is the default value for the CXX_STANDARD
# target property
if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_EXTENSIONS OFF)
else()
  message(STATUS "CMAKE_CXX_STANDARD already set to ${CMAKE_CXX_STANDARD}")
endif()

include(cmake/setup_install.cmake)

#
# Generate kalypsso_config.h and kalypsso_version.h (with git info and build date)
#
include(cmake/generate_config_h.cmake)

# ##################################################################################################
# ##################################################################################################
# now we build kalypsso-app-pub
# ##################################################################################################
# ##################################################################################################

include(cmake/build_or_find_kalypsso_core.cmake)

# build kalypsso-app-pub
add_subdirectory(src)

# include(CTest)

# add_subdirectory(test)

# add target kalypsso-test if(KALYPSSO_APP_PUB_ENABLE_UNIT_TESTING) add_subdirectory(unit_test)
# endif(KALYPSSO_APP_PUB_ENABLE_UNIT_TESTING)

# add target kalypsso-app-pub-doc
if(KALYPSSO_APP_PUB_BUILD_DOC)
  add_subdirectory(doc)
endif(KALYPSSO_APP_PUB_BUILD_DOC)

# ##################################################################################################
# Install ####
# ##################################################################################################
include(cmake/setup_install.cmake)

set(TARGETS_LIST)

# if (KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_HYDRO) list(APPEND TARGETS_LIST godunov_hydro)
# endif(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_HYDRO)

# Use a namespace because CMake provides better diagnostics for namespaced imported targets. export(
# TARGETS ${TARGETS_LIST} NAMESPACE ${PROJECT_NAME_SC}:: FILE
# ${PROJECT_BINARY_DIR}/kalypsso-app-pub-targets.cmake)

# install( EXPORT kalypsso-app-pub-targets NAMESPACE kalypsso:: FILE kalypsso-app-pub-targets.cmake
# DESTINATION ${INSTALL_CMAKE_DIR})

#
# Install cmake related files (targets, exports, ...)
#

set(VERSION_CONFIG ${PROJECT_BINARY_DIR}/${PROJECT_NAME_SC}-config-version.cmake)
set(PROJECT_CONFIG_SRC ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME_SC}-config.cmake.in)
set(PROJECT_CONFIG_DST ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_SC}-config.cmake)

install(FILES ${PROJECT_CONFIG_DST} ${VERSION_CONFIG} DESTINATION ${INSTALL_CMAKE_DIR})

include(CMakePackageConfigHelpers)

# Generate the version, config and target files into the build directory.
write_basic_package_version_file(
  ${VERSION_CONFIG}
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion)

# generate cmake my_package-config.cmake file
configure_package_config_file(${PROJECT_CONFIG_SRC} ${PROJECT_CONFIG_DST}
                              INSTALL_DESTINATION ${INSTALL_CMAKE_DIR})
