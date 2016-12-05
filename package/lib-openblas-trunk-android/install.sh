#! /bin/bash

#
# Installation script for clBLAS.
#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2015;
# - Anton Lokhmotov, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

cd ${INSTALL_DIR}

############################################################
echo ""
echo "Cloning package from '${PACKAGE_URL}' ..."

rm -rf src

git clone ${PACKAGE_URL} src

if [ "${?}" != "0" ] ; then
  echo "Error: cloning package failed!"
  exit 1
fi

############################################################
echo ""
echo "Cleaning ..."

cd ${INSTALL_DIR}
cd src

############################################################
echo ""
echo "Building ..."

if [ "${CK_ANDROID_ABI}" = "arm64-v8a"  ]; then
  NO_LAPACK=${NO_LAPACK:-1}
  TARGET=ARMV8
elif [ "${CK_ANDROID_ABI}" = "armeabi"  ]; then
  NO_LAPACK=1
  TARGET=ARMV5
elif [ "${CK_ANDROID_ABI}" = "armeabi-v7a"  ]; then
  NO_LAPACK=1
  TARGET=ARMV7
elif [ "${CK_ANDROID_ABI}" = "x86"  ]; then
  NO_LAPACK=1
  TARGET=ATOM
elif [ "${CK_ANDROID_ABI}" = "x86_64"  ]; then
  NO_LAPACK=1
  TARGET=ATOM
else
  echo "Error: ${CK_ANDROID_ABI} is not supported!"
  exit 1
fi

make -j${CK_HOST_CPU_NUMBER_OF_PROCESSORS} \
     CC="${CK_CC} ${CK_COMPILER_FLAGS_OBLIGATORY}" \
     FC="xyz" \
     CROSS_SUFFIX=${CK_ENV_COMPILER_GCC_BIN}/${CK_COMPILER_PREFIX} \
     HOSTCC=gcc USE_THREAD=1 NUM_THREADS=8 USE_OPENMP=1 \
     NO_LAPACK=$NO_LAPACK \
     TARGET=$TARGET \
     BINARY=${CK_CPU_BITS}

if [ "${?}" != "0" ] ; then
  echo "Error: cmake failed!"
  exit 1
fi

############################################################
echo ""
echo "Installing package ..."

rm -rf install

make PREFIX="${INSTALL_DIR}/install" install
if [ "${?}" != "0" ] ; then
  echo "Error: installation failed!"
  exit 1
fi

exit 0
