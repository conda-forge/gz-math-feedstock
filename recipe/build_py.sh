#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cd ${SRC_DIR}/src/python_pybind11

rm -rf build
mkdir build
cd build

echo "Setting Python3_INCLUDE_DIR to "$PREFIX/include/`ls $PREFIX/include | grep "python\|pypy"`


cmake ${CMAKE_ARGS} -GNinja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DUSE_SYSTEM_PATHS_FOR_PYTHON_INSTALLATION:BOOL=ON \
    -DPython3_EXECUTABLE:PATH=$PYTHON \
    -DPYTHON_EXECUTABLE:PATH=$PYTHON \
    -DPython3_INCLUDE_DIR:PATH=$PREFIX/include/`ls $PREFIX/include | grep "python\|pypy"`

cmake --build . --config Release
cmake --build . --config Release --target install

# Run tests
cd ../test

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]];then
  pytest *.py
fi
