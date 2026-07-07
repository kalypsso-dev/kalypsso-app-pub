<!--
SPDX-FileCopyrightText: 2025 kalypsso-app authors

SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
-->

<!--
![C/C++ build](https://github.com/kalypsso-dev/kalypsso-app-public/actions/workflows/ci.yaml/badge.svg?branch=main)
-->

# What is kalypsso-app ?

kalypsso-app is a companion code to [kalypsso-core](https://github.com/kalypsso-dev/kalypsso-core), which provides octree-based block-structured AMR (adaptive mesh refinement) core application agnostic building blocks, while kalypsso-app provides actual actual [CFD](https://en.wikipedia.org/wiki/Computational_fluid_dynamics) example applications.

Let's remind that:
- 2d/3d distributed memory AMR mesh management is implemented through a thin layer on top of [p4est](https:://github.com/cburstedde/p4est)
- we use the C++ [kokkos](https://github.com/kokkos/kokkos) library for shared memory parallelism and performance portability across all current HPC hardware architectures (from `x86_64` or ARM CPU to NVIDIA or AMD GPUs).

You will find more technical details about kalypsso in the following article:

- Kestener, Pierre, Kalypsso: A Performance Portable Platform for Compressible Hydrodynamics Simulations using Adaptive Mesh Refinement. https://doi.org/10.1016/j.cpc.2026.110275


# Example applications

We currently provide three example applications which all relates to compressible flows, solved using a finite volumes method.

- `godunov_hydro`: solves the [compressible Euler equations](https://en.wikipedia.org/wiki/Euler_equations_(fluid_dynamics)) using a direct Euler approach, more precisely the second order in time and space MUSCL-Hancock numerical scheme.
- `godunov_five_eq`: solves the so-called `Five equation system` which models the dynamics of a two compressible fluids
- `godunov_mhd_ct`: solves ideal compressible [MHD](Magnetohydrodynamics) (magnetohydrodynamics) using again a finite volume approach derived from [Fromang et al](https://doi.org/10.1051/0004-6361:20065371) (also implemented in [RAMSES](https://github.com/ramses-organisation/ramses)) where the magnetic field is evolved with the [constraint transport]() method to preserve magnetic field divergence-free property.


# How to build ?

## Get the source code

Make sure to clone this repository recursively, this will also download kalypsso-core (and its own dependencies) source as a git submodule.

```bash
git clone --recurse-submodules git@github.com:kalypsso-dev/kalypsso-app-pub.git
```

kalypsso-core (and its dependencies, i.e. kokkos and p4est) will (optionally) be built as part of kalypsso-app with the cmake build system.

## Prerequisites

kalypsso-app external dependencies are:

- [kalypsso-core](https://github.com/kalypsso-dev/kalypsso-core)

building kalypsso-core also requires:
- [kokkos](https://github.com/kokkos/kokkos) 4.7.0
- [p4est](https://github.com/cburstedde/p4est) 2.8.7
- [spdlog](https://github.com/gabime/spdlog)
- [HighFive](https://highfive-devs.github.io/highfive/) and also HDF5 (preferably a parallel version of HDF5)
- [better-enums](https://aantron.github.io/better-enums/)
- optional [cpptrace](https://github.com/jeremy-rifkin/cpptrace)
- optional [cnpy](https://github.com/pkestene/cnpy-cmake) for numpy array outputs

You'll also need [cmake](https://cmake.org/) (minimum version 3.18) and optionally an [MPI](https://www.mpi-forum.org/) implementation (only )

These dependencies can either be :
- built along kalypsso (most convenient and recommended for a beginner)
- built in a separate cmake sub-project (located in sub-directory `dependencies`); this third option is a bit cleaner, it additionally provides a modulefiles to ease the use of these dependencies.

## Let's build kalypsso-app

### build kalypsso-app and its dependencies all together

You can chose to build kalypsso-app and its dependencies (kalypsso-core, kokkos, p4est) all together at once.

Here is an example command line to build `kalypsso-app` and `kalypsso-core` for Kokkos/OpenMP backend target (which is the default):

```bash
cd kalypsso-app
cmake -B _build/openmp -S . \
   -DKALYPSSO_APP_KALYPSSO_CORE_BUILD:BOOL=ON \
   -DKALYPSSO_CORE_KOKKOS_BUILD:BOOL=ON \
   -DKALYPSSO_CORE_KOKKOS_BACKEND=OpenMP \
   -DKALYPSSO_CORE_BUILD_P4EST:BOOL=ON
cmake --build _build/openmp -j 8
```

Cmake variable `KALYPSSO_APP_KALYPSSO_CORE_BUILD` is a boolean variable used to trigger building `kalypsso-core`. Here we do want to build `kalypsso-core`.
Other cmake variable prefixed with `KALYPSSO_CORE` are directly passed to `kalypsso-core` build system and used to specify (among other things) which kokkos default backend we want (see `kalypsso-core` documentation for more information).

Please note that library spdlog is a required dependency. If spdlog is not already installed on your system, you can ask kalypsso-core to build it for you by adding option `-DKALYPSSO_CORE_BUILD_SPDLOG=ON`

Also note that by default, only the simple monofuid application will be built; you must explicitly turn cmake options to enable building the other applications.

Here is the same command lines for building with Kokkos/CUDA backend
```bash
cd kalypsso-app
cmake -B _build/cuda -S . \
   -DKALYPSSO_APP_KALYPSSO_CORE_BUILD:BOOL=ON \
   -DKALYPSSO_CORE_KOKKOS_BUILD:BOOL=ON \
   -DKALYPSSO_CORE_KOKKOS_BACKEND=Cuda \
   -DKALYPSSO_CORE_BUILD_P4EST:BOOL=ON
cmake --build _build/cuda -j 8
```

Important note regarding Kokkos/Cuda backend:
- if you build on the same platform as the one used to run `kalypsso-app`, you're all set, kokkos build system will auto-detect GPU architecture;
- if you build on a different system, you need to specify the target architecture, e.g. `-DKokkos_ARCH_HOPPER90=ON` (for Nvidia Hopper aka `sm_90` architecture). Run `ccmake --build _build/cuda` to navigate all available Kokkos architecture cmake options;
- using a Cuda-aware MPI implementation is absolutely required only if you plan to use more than one GPU. So by default, MPI implementation is expected to by cuda-aware. Conversely, if you only have access to machine that has a single GPU, you can safely deactivate the use of MPI; to do that just use cmake variable `KALYPSSO_CORE_USE_MPI=OFF`.

Please note that you don't have to specify environment variable CXX (set to `nvcc_wrapper` when targeting CUDA backend), each sub-project (p4est / Kokkos / Kalypsso) is built with a custom specific `CMAKE_CXX_COMPILER` variable; if `KALYPSSO_CORE_KOKKOS_BACKEND` is `Cuda`, internally `nvcc_wrapper` will be selected to build both Kokkos, kalypsso-core and kalypsso-app.

# More information

## Build developer documentation

### Requirements

- [doxygen](https://www.doxygen.nl/)
- (optional, but recommended) [mkdocs](https://www.mkdocs.org/) for building a static webpage with documentation, written in markdown, with [MkDoxy plugin](https://github.com/JakubAndrysek/MkDoxy)
   ```shell
   # we recommend using miniconda for installing python packages
   conda create -n MkDoxy
   conda activate MkDoxy
   conda install pip
   cd doc
   pip install -r requirements.txt
   ```

### [doxygen](https://www.doxygen.nl/)

```shell
# re-run cmake with additional options
cmake -B _build/doc -S . -DKALYPSSO_APP_BUILD_DOC=ON -DKALYPSSO_APP_DOC=doxygen
cd _build/doc
make
make doxygen
```

This will generate the html doxygen page in `doc/doxygen/html`

### [mkdocs](https://www.mkdocs.org/) with [MkDoxy plugin](https://github.com/JakubAndrysek/MkDoxy)

```shell
cmake -B _build/doc -S . -DKALYPSSO_APP_BUILD_DOC=ON -DKALYPSSO_APP_DOC=mkdocs
make
make mkdocs
```

This will generate the markdown sources for the mkdocs static webpage.

```shell
# from the build directory
cd doc/mkdocs

# preview of the webpage
mkdocs serve
# open url localhost:8000

# if you want to build the html sources (before deployment)
mkdocs build

# this will create directory `site` that can directly be uploaded to
# a web server
```

# Citing kalypsso

If you use this software, please cite it using the following reference.

```
@article{kalypsso_core_cpc26,
  author={Kestener, Pierre},
  journal={Computer Physics Communication},
  title={kalypsso: a performance portable platform for compressible hydrodynamics simulations using adaptive mesh refinement},
  year={2026},
  volume={},
  number={},
  pages={},
  doi={10.1016/j.cpc.2026.110275}}
  ```
