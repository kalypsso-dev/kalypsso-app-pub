if(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_HYDRO)
  add_subdirectory(godunov_hydro)
endif()

if(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_FIVE_EQ)
  add_subdirectory(godunov_five_eq)
endif()

if(KALYPSSO_APP_PUB_ENABLE_SOLVER_GODUNOV_MHD_CT)
  add_subdirectory(godunov_mhd_ct)
endif()
