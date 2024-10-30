#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cd ${SRC_DIR}/src/python_pybind11

rm -rf build
mkdir build
cd build

# See https://github.com/conda-forge/conda-forge.github.io/pull/2321
Python_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"

cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DUSE_SYSTEM_PATHS_FOR_PYTHON_INSTALLATION:BOOL=ON

cmake --build . --config Release
cmake --build . --config Release --target install

# Run tests
cd ../test

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]];then
  pytest *.py
fi
