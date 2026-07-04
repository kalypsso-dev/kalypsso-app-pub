include(${CMAKE_SOURCE_DIR}/cmake/add_subdirectory_if_not_empty.cmake)

if(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_HYDRO)
  add_subdirectory_if_not_empty(godunov_hydro)
endif()

if(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_FIVE_EQ)
  add_subdirectory_if_not_empty(godunov_five_eq)
endif()

if(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_MHD_CT)
  add_subdirectory_if_not_empty(godunov_mhd_ct)
endif()
