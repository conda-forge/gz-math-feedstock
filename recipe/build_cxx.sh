#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# INTEGRATION_ExamplesBuild_TEST does not work during cross-compilation, probalby because
# crosscompilation options are not passed along
# UNIT_Helpers_TEST fail due to some slightly different floating point results
# UNIT_Stopwatch_TEST is flaky
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
    export CTEST_OPTIONS="-E INTEGRATION_ExamplesBuild_TEST|UNIT_Helpers_TEST|UNIT_Stopwatch_TEST  "
else
    export CTEST_OPTIONS="-E INTEGRATION_ExamplesBuild_TEST|UNIT_Stopwatch_TEST "
fi

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DSKIP_PYBIND11:BOOL=ON \
      -DSKIP_SWIG:BOOL=ON

cmake --build . --config Release
cmake --build . --config Release --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release ${CTEST_OPTIONS}
fi
