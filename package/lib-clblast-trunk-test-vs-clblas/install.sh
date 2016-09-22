#! /bin/bash

#
# Installation script for CLBlast.
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

export CLBLAST_SRC_DIR=${INSTALL_DIR}/src
export CLBLAST_BLD_DIR=${INSTALL_DIR}/bld
export CLBLAST_TST_LOG=${INSTALL_DIR}/tst.log
export CLBLAST_BLD_LOG=${INSTALL_DIR}/bld.log

export CLBLAST_PATCH=${PACKAGE_DIR}/test_correctness_common_ref_includes.patch

# Must be set before running CMake.
# TODO: Set to CK environment.
export CLBLAST_PLATFORM=0
export CLBLAST_DEVICE=0

################################################################################
echo ""
echo "Cloning CLBlast from '${CLBLAST_URL}' ..."
rm -rf ${CLBLAST_SRC_DIR}
git clone ${CLBLAST_URL} --no-checkout ${CLBLAST_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning CLBlast from '${CLBLAST_URL}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Checking out the '${CLBLAST_BRANCH}' branch of CLBlast ..."
cd ${CLBLAST_SRC_DIR}
git checkout ${CLBLAST_BRANCH}
if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${CLBLAST_BRANCH}' branch of CLBlast failed!"
  exit 1
fi

################################################################################
echo ""
echo "Patching the '${CLBLAST_BRANCH}' branch of CLBlast ..."
cd ${CLBLAST_SRC_DIR}
patch -p1 < ${CLBLAST_PATCH}
if [ "${?}" != "0" ] ; then
  echo "Error: Patching the '${CLBLAST_BRANCH}' branch of CLBlast failed!"
  exit 1
fi

################################################################################
echo ""
echo "Building the '${CLBLAST_BRANCH}' branch of CLBlast ..."
echo "Logging into '${CLBLAST_BLD_LOG}' ..."
touch ${CLBLAST_BLD_LOG}

echo "** DATE **" >> ${CLBLAST_BLD_LOG}
date >> ${CLBLAST_BLD_LOG}

echo "** SET **" >> ${CLBLAST_BLD_LOG}
set >> ${CLBLAST_BLD_LOG}

rm -rf ${CLBLAST_BLD_DIR}
mkdir -p ${CLBLAST_BLD_DIR}
cd ${CLBLAST_BLD_DIR}

echo "** CMAKE **" >> ${CLBLAST_BLD_LOG}
cmake ${CLBLAST_SRC_DIR} \
  -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
  -DCMAKE_C_COMPILER=${CK_CC} -DCMAKE_CXX_COMPILER=${CK_CXX} \
  -DOPENCL_LIBRARIES:FILEPATH=${CK_ENV_LIB_OPENCL_LIB}/${CK_ENV_LIB_OPENCL_DYNAMIC_NAME} \
  -DOPENCL_INCLUDE_DIRS:PATH=${CK_ENV_LIB_OPENCL_INCLUDE} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR} \
  -DTESTS=ON \
  -DCLBLAS_INCLUDE_DIRS:PATH=${CK_ENV_LIB_CLBLAS_INCLUDE} \
  -DCLBLAS_LIBRARIES:FILEPATH=${CK_ENV_LIB_CLBLAS_LIB}/${CK_ENV_LIB_CLBLAS_DYNAMIC_NAME} \
  >>${CLBLAST_BLD_LOG} 2>&1

echo "** MAKE **" >> ${CLBLAST_BLD_LOG}
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} >>${CLBLAST_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Building the '${CLBLAST_BRANCH}' branch of CLBlast failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Installed the '${CLBLAST_BRANCH}' branch of CLBlast into '${INSTALL_DIR}'."

################################################################################
echo ""
echo "Testing the '${CLBLAST_BRANCH}' branch of CLBlast ..."
echo "Logging into '${CLBLAST_TST_LOG}' ..."
touch ${CLBLAST_TST_LOG}

make alltests >>${CLBLAST_TST_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Warning: Testing the '${CLBLAST_BRANCH}' branch of CLBlast failed!"
fi
