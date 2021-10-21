#!/bin/bash

set -x

if [[ $(uname) == Darwin ]]; then
  ${SYS_PREFIX}/bin/conda create -y -p ${SRC_DIR}/bootstrap clangxx_osx-64
  export PATH=${SRC_DIR}/bootstrap/bin:${PATH}
  CONDA_PREFIX=${SRC_DIR}/bootstrap \
    . ${SRC_DIR}/bootstrap/etc/conda/activate.d/*
  export CONDA_BUILD_SYSROOT=${CONDA_BUILD_SYSROOT:-/opt/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk}
  export CXXFLAGS=${CFLAGS}" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  export CFLAGS=${CFLAGS}" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  SYSROOT_DIR=${CONDA_BUILD_SYSROOT}
  CFLAG_SYSROOT="--sysroot ${SYSROOT_DIR}"
  # export LLVM_CONFIG explicitly as the one installed from llvmdev
  # in the build root env, the one in the bootstrap location needs to be ignored.
  export LLVM_CONFIG="${PREFIX}/bin/llvm-config"
  ${LLVM_CONFIG} --version
fi

if [ -n "$MACOSX_DEPLOYMENT_TARGET" ]; then
    # OSX needs 10.7 or above with libc++ enabled
    export MACOSX_DEPLOYMENT_TARGET=10.10
fi

DARWIN_TARGET=x86_64-apple-darwin13.4.0


export PYTHONNOUSERSITE=1
# Enables static linking of stdlibc++
export LLVMLITE_CXX_STATIC_LINK=1
export LLVMLITE_SKIP_LLVM_VERSION_CHECK=1
config=/home/taanders/github/Python-for-HPC/PyOMP/llvm-project-install/bin/llvm-config

export LLVM_CONFIG=$config
export CC=gcc-9
export CXX=g++-9


EXTRA_LLVM_LIBS="-L /opt/intel/intelpython3/lib -fno-lto" LDFLAGS=-fPIC LLVM_CONFIG=$config $PYTHON setup.py build --force
EXTRA_LLVM_LIBS="-L /opt/intel/intelpython3/lib -fno-lto" LLVM_CONFIG=$config $PYTHON setup.py install
