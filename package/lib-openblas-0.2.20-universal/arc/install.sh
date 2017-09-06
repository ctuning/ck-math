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
echo "Patching ..."

cd ${INSTALL_DIR}/src
patch -p1 < ${PACKAGE_DIR}/misc/patch

if [ "${?}" != "0" ] ; then
  echo "Error: cloning package failed!"
  exit 1
fi

############################################################
echo ""
echo "Building ..."

cd ${INSTALL_DIR}
cd src

if [ "${CK_ANDROID_ABI}" = "arm64-v8a"  ]; then
  NO_LAPACK=${NO_LAPACK:-1}
  TARGET=ARMV8
elif [ "${CK_ANDROID_ABI}" = "armeabi"  ]; then
  NO_LAPACK=1
  TARGET=ARMV5
elif [ "${CK_ANDROID_ABI}" = "armeabi-v7a"  ]; then
  # ARMV7 can be used only with hardfp and neon - see later
  NO_LAPACK=1
  TARGET=ARMV5
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

CK_OPENMP=1
if [ "${CK_HAS_OPENMP}" = "0"  ]; then
  CK_OPENMP=0
fi

############################################################
# Check extra stuff
EXTRA_FLAGS=""

if [ "${CK_CPU_ARM_NEON}" == "ON" ] ; then
  EXTRA_FLAGS=" $EXTRA_FLAGS -mfpu=neon"
  TARGET=ARMV7
fi

if [ "${CK_CPU_ARM_VFPV3}" == "ON" ] ; then
  EXTRA_FLAGS=" $EXTRA_FLAGS -mfpu=vfpv3"
  TARGET=ARMV7
fi

make VERBOSE=1 -j${CK_HOST_CPU_NUMBER_OF_PROCESSORS} \
     CC="${CK_CC} ${CK_COMPILER_FLAGS_OBLIGATORY} ${CK_CC_FLAGS_FOR_CMAKE} ${CK_CC_FLAGS_ANDROID_TYPICAL} ${EXTRA_FLAGS}" \
     AR="${CK_AR}" \
     FC="no-fc" \
     CROSS_SUFFIX=${CK_ENV_COMPILER_GCC_BIN}/${CK_COMPILER_PREFIX} \
     HOSTCC=gcc \
     USE_THREAD=1 \
     NUM_THREADS=8 \
     USE_OPENMP=${CK_OPENMP} \
     NO_LAPACK=$NO_LAPACK \
     TARGET=$TARGET \
     BINARY=${CK_CPU_BITS} \
     CK_COMPILE=ON \

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
