#! /bin/bash

#
# Installation script for OpenBLAS.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Anton Lokhmotov, anton@dividiti.com, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

# Configure ARM target.
MACHINE=$(uname -m)
if [ "${MACHINE}" == "armv7l" ] || [ "${CK_TARGET_CPU_BITS}" == "32" ]; then
  TARGET="TARGET=ARMV7"
elif [ "${MACHINE}" == "aarch64" ]; then
  TARGET="TARGET=ARMV8"
fi

# Configure ARM target. An alternative way.
if [ "${HOSTTYPE}" == "armv7a" ]; then
  TARGET="TARGET=ARMV7"
elif [ "${HOSTTYPE}" == "aarch64" ]; then
  TARGET="TARGET=ARMV8"
fi

# Configure ARM target on Android.
if [ "${CK_ANDROID_NDK_ARCH}" == "arm" ] ; then
  TARGET="OSNAME=Android TARGET=ARMV7"
elif [ "${CK_ANDROID_NDK_ARCH}" == "arm64" ] ; then
  TARGET="OSNAME=Android TARGET=ARMV8"
fi

if [ "${OPENBLAS_TARGET}" != "" ] ; then
  TARGET="TARGET=${OPENBLAS_TARGET}"
fi

EXTRA2="NOFORTRAN=1"
if [ "${OPENBLAS_FORTRAN}" == "YES" ] ; then
  EXTRA2=""
fi

EXTRA3="NOLAPACK=1"
if [ "${OPENBLAS_LAPACK}" == "YES" ] ; then
  EXTRA3=""
fi

export CC=${CK_CC}
export FC=${CK_FC}
export AR=${CK_AR}

# Building OpenBLAS produces lots of output which gets redirected to file.
cd ${INSTALL_DIR}/${PACKAGE_SUB_DIR}

make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} ${TARGET} ${EXTRA2} ${EXTRA3}
if [ "${?}" != "0" ] ; then
  echo "Error: Building of OpenBLAS failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Installing ..."

make PREFIX=${INSTALL_DIR}/install install
if [ "${?}" != "0" ] ; then
  echo "Error: Installing of OpenBLAS failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Installed OpenBLAS into '${INSTALL_DIR}/install'."

export PACKAGE_SKIP_LINUX_MAKE=YES

return 0
