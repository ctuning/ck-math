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
echo "Building the '${CLBLAST_BRANCH}' branch of CLBlast ..."

rm -rf ${CLBLAST_BLD_DIR}

mkdir -p ${CLBLAST_BLD_DIR}
cd ${CLBLAST_BLD_DIR}

cmake ${CLBLAST_SRC_DIR} \
  -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
  -DCMAKE_C_COMPILER="${CK_CC_PATH_FOR_CMAKE}" \
  -DCMAKE_CXX_COMPILER="${CK_CXX_PATH_FOR_CMAKE}" \
  -DCMAKE_C_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE}" \
  -DCMAKE_CXX_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE}" \
  -DOPENCL_ROOT=${CK_ENV_LIB_OPENCL} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR}

#  -DOPENCL_LIBRARIES:FILEPATH=${CK_ENV_LIB_OPENCL_LIB}/${CK_ENV_LIB_OPENCL_DYNAMIC_NAME} \
#  -DOPENCL_INCLUDE_DIRS:PATH=${CK_ENV_LIB_OPENCL_INCLUDE} \

################################################################################
echo ""
echo "Building ..."

make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} install
if [ "${?}" != "0" ] ; then
  echo "Error: Building failed!"
  exit 1
fi
