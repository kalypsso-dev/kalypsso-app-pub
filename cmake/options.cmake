#
# Declare optional features
#

#
# numerics options
#
option(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_HYDRO
       "build kalypsso-app with Godunov hydro solver using MUSCL-Hancock (default ON)" ON)
option(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_FIVE_EQ
       "build kalypsso-app with Godunov bifluid (5-equations) solver (default OFF)" OFF)
option(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_MHD_CT
       "build kalypsso-app with Godunov MHD solver with constraint transport (default OFF)" OFF)

#
# documentation related options
#
option(KALYPSSO_APP_PUB_BUILD_DOC "Enable / disable documentation build" OFF)

# documentation type - the only valid values are : doxygen and mkdocs
if(NOT KALYPSSO_APP_PUB_DOC)
  set(KALYPSSO_APP_PUB_DOC
      "doxygen"
      CACHE STRING "documentation type (doxygen or mkdocs)" FORCE)
  set_property(CACHE KALYPSSO_APP_PUB_DOC PROPERTY STRINGS "doxygen" "mkdocs")
endif()

# option(KALYPSSO_APP_PUB_ENABLE_UNIT_TESTING "Enable unit testing" OFF)
