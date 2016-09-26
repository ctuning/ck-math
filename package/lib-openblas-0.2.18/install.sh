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

export OPENBLAS_SRC_DIR=${INSTALL_DIR}/src
export OPENBLAS_BLD_DIR=${OPENBLAS_SRC_DIR}
export OPENBLAS_BLD_LOG=${OPENBLAS_BLD_DIR}/build.log

################################################################################
echo ""
echo "Cloning OpenBLAS from '${OPENBLAS_URL}' ..."

rm -rf ${OPENBLAS_SRC_DIR}
git clone ${OPENBLAS_URL} --no-checkout ${OPENBLAS_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning OpenBLAS from '${OPENBLAS_URL}' failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Checking out the '${OPENBLAS_TAG}' release of OpenBLAS ..."

cd ${OPENBLAS_SRC_DIR}
git checkout tags/${OPENBLAS_TAG} -b ${OPENBLAS_TAG}
if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${OPENBLAS_TAG}' release of OpenBLAS failed!"
  exit 1
fi

################################################################################
echo
echo "Logging into '${OPENBLAS_BLD_LOG}' ..."

mkdir -p ${OPENBLAS_BLD_DIR}
touch ${OPENBLAS_BLD_LOG}; sleep 0.5

echo "** DATE **" >> ${OPENBLAS_BLD_LOG}
date >> ${OPENBLAS_BLD_LOG}

echo "** SET **" >> ${OPENBLAS_BLD_LOG}
set >> ${OPENBLAS_BLD_LOG}

###############################################################################
echo ""
echo "Building the '${OPENBLAS_TAG}' release of OpenBLAS ..."
echo "** BUILD **" >> ${OPENBLAS_BLD_LOG}

# Configure ARM target.
MACHINE=$(uname -m)
if [ "${MACHINE}" == "armv7l" ]; then
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

export CC=${CK_CC}
export FC=${CK_FC}
export AR=${CK_AR}

# Building OpenBLAS produces lots of output which gets redirected to file.
cd ${OPENBLAS_BLD_DIR}
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} ${TARGET} >>${OPENBLAS_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Building the '${OPENBLAS_TAG}' release of OpenBLAS failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Installing the '${OPENBLAS_TAG}' release of OpenBLAS ..."
echo "** INSTALL **" >> ${OPENBLAS_BLD_LOG}

cd ${OPENBLAS_BLD_DIR}
make PREFIX=${INSTALL_DIR} install >>${OPENBLAS_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Installing the '${OPENBLAS_TAG}' release of OpenBLAS failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Installed OpenBLAS ${OPENBLAS_TAG} into '${INSTALL_DIR}'."
