#! /bin/bash

#
# Installation script for CLTune.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2015;
# - Anton Lokhmotov, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

export CLTUNE_SRC_DIR=${INSTALL_DIR}/src
export CLTUNE_BLD_DIR=${INSTALL_DIR}/bld
export CLTUNE_TST_LOG=${INSTALL_DIR}/tst.log
export CLTUNE_BLD_LOG=${INSTALL_DIR}/bld.log

# NB: List of pending patches (PRs or otherwise) to this CLTune branch.
# When no pending patches, comment out the patch command below.

# NB: Must be set before running CMake.
export CLTUNE_PLATFORM=${CK_COMPUTE_PLATFORM_ID:-0}
export CLTIME_DEVICE=${CK_COMPUTE_DEVICE_ID:-0}

################################################################################
echo ""
echo "Cloning CLTune from '${CLTUNE_URL}' ..."
rm -rf ${CLTUNE_SRC_DIR}
git clone ${CLTUNE_URL} --no-checkout ${CLTUNE_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning CLTune from '${CLTUNE_URL}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Checking out the '${CLTUNE_BRANCH}' branch of CLTune ..."
cd ${CLTUNE_SRC_DIR}
git checkout ${CLTUNE_BRANCH}
if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${CLTUNE_BRANCH}' branch of CLTune failed!"
  exit 1
fi

################################################################################
echo ""
echo "Patching the '${CLTUNE_BRANCH}' branch of CLTune ..."
cd ${CLTUNE_SRC_DIR}
#patch -p1 < ${CLTUNE_PR102_PATCH}
if [ "${?}" != "0" ] ; then
  echo "Error: Patching the '${CLTUNE_BRANCH}' branch of CLTune failed!"
  exit 1
fi

################################################################################
echo ""
echo "Logging into '${CLTUNE_BLD_LOG}' ..."

rm -rf ${CLTUNE_BLD_DIR}; mkdir -p ${CLTUNE_BLD_DIR}
touch ${CLTUNE_BLD_LOG}; sleep 0.5

echo "** DATE **" >> ${CLTUNE_BLD_LOG}
date >> ${CLTUNE_BLD_LOG}

echo "** SET **" >> ${CLTUNE_BLD_LOG}
set >> ${CLTUNE_BLD_LOG}

################################################################################
echo ""
echo "Configuring the '${CLTUNE_BRANCH}' branch of CLTune ..."
echo "** CMAKE **" >> ${CLTUNE_BLD_LOG}

cd ${CLTUNE_BLD_DIR}
cmake ${CLTUNE_SRC_DIR} \
  -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
  -DCMAKE_C_COMPILER=${CK_CC} \
  -DCMAKE_CXX_COMPILER=${CK_CXX} \
  -DOPENCL_LIBRARIES:FILEPATH=${CK_ENV_LIB_OPENCL_LIB}/${CK_ENV_LIB_OPENCL_DYNAMIC_NAME} \
  -DOPENCL_INCLUDE_DIRS:PATH=${CK_ENV_LIB_OPENCL_INCLUDE} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR} \
  -DCLTUNE_INCLUDE_DIRS:PATH=${CK_ENV_LIB_CLTUNE_INCLUDE} \
  -DCLTUNE_LIBRARIES:FILEPATH=${CK_ENV_LIB_CLTUNE_LIB}/${CK_ENV_LIB_CLTUNE_DYNAMIC_NAME} \
  -DSAMPLES=ON
#  >>${CLTUNE_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Configuring the '${CLTUNE_BRANCH}' branch of CLTune failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Building the '${CLTUNE_BRANCH}' branch of CLTune ..."
echo "** MAKE **" >> ${CLTUNE_BLD_LOG}

cd ${CLTUNE_BLD_DIR}
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} install >>${CLTUNE_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Building the '${CLTUNE_BRANCH}' branch of CLTune failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Installed the '${CLTUNE_BRANCH}' branch of CLTune into '${INSTALL_DIR}'."

################################################################################
echo ""
echo "Testing the '${CLTUNE_BRANCH}' branch of CLBlast ..."
echo "Logging into '${CLTUNE_TST_LOG}' ..."
cd ${CLTUNE_BLD_DIR}
touch ${CLTUNE_TST_LOG}; sleep 0.5

./sample_simple >>${CLTUNE_TST_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Warning: Testing the '${CLTUNE_BRANCH}' branch of CLTune failed!"
fi
