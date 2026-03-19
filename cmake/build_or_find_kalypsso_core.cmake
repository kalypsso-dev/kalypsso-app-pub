# Two alternatives:
#
# 1. If KALYPSSO_APP_KALYPSSO_CORE_BUILD is ON, we download kalypsso-core sources and build them using FetchContent (which
#    actually uses add_subdirectory)
# 2. If KALYPSSO_APP_KALYPSSO_CORE_BUILD is OFF (default), we don't build kalypsso-core, but use find_package for setup
#    (you must have kalypsso_core already installed)

#
# Does kalypsso-app builds kalypsso-core ?
#
option(KALYPSSO_APP_KALYPSSO_CORE_BUILD "Turn ON if you want to build kalpysso-core (default: OFF)"
       OFF)

#
# Option to use git (instead of tarball release) for downloading kalypsso-core
#
option(KALYPSSO_APP_KALYPSSO_CORE_USE_GIT
       "Turn ON if you want to use git to download kalypsso-core sources (default: OFF)" OFF)

# check if user requested a build of kalypsso-core
if(KALYPSSO_APP_KALYPSSO_CORE_BUILD)

  message("[kalypsso-app / kkalypsso-core] Building kalypsso-core from source")

  set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/external)

  # kalypsso-core default build options

  # set install path
  list(APPEND KALYPSSO_APP_KALYPSSO_CORE_CMAKE_ARGS
       -DCMAKE_INSTALL_PREFIX=${KALYPSSO_CORE_INSTALL_DIR})

  # find_package(Git REQUIRED)
  include(FetchContent)

  if(KALYPSSO_APP_KALYPSSO_CORE_USE_GIT)
    FetchContent_Declare(
      kalypsso_core_external
      SYSTEM
      GIT_REPOSITORY https://github.com/pkestene/kalypsso-core-priv.git
      GIT_TAG main)
  else()
    FetchContent_Declare(kalypsso_core_external SYSTEM SOURCE_DIR
                                                ${PROJECT_SOURCE_DIR}/external/kalypsso-core)
  endif()

  # Import kalypsso-core targets (download, and call add_subdirectory)
  FetchContent_MakeAvailable(kalypsso_core_external)

  if(TARGET kalypsso::core)
    message("[kalypsso-app / kalypsso-core] kalypsso-core found (using FetchContent)")
    set(KALYPSSO_APP_KALYPSSO_CORE_FOUND True)
    set(HAVE_KALYPSSO_CORE 1)
  else()
    message(
      "[kalypsso-app / kalypsso-core] we shouldn't be here. We've just integrated kalypsso-core build into kalypsso-app build !"
    )
  endif()

  set(KALYPSSO_APP_KALYPSSO_CORE_BUILTIN TRUE)

else()

  #
  # check if an already installed kalypsso-core exists
  #
  find_package(kalypsso-core 1.0.0 CONFIG REQUIRED)

  if(TARGET kalypsso::core)

    message("[kalypsso-app / kalypsso-core] kalypsso-core found via find_package")
    set(KALYPSSO_APP_KALYPSSO_CORE_FOUND True)
    set(HAVE_KALYPSSO_CORE 1)

  else()

    message(
      FATAL_ERROR
        "[kalypsso-app / kalypsso-core] kalypsso-core is required but not found by find_package. Please adjust your env variable CMAKE_PREFIX_PATH (or kalypsso_core_ROOT) to where kalypsso-core is installed on your machine !"
    )

  endif()

endif()
