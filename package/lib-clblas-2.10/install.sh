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

export CLBLAS_SRC_DIR=${INSTALL_DIR}/src
export CLBLAS_OBJ_DIR=${INSTALL_DIR}/obj
export CLBLAS_PATCH_PATH=${PACKAGE_DIR}/clblas.patch
export CLBLAS_INSTALL_DIR=${INSTALL_DIR}

echo ""
echo "Cloning clBLAS from '${CLBLAS_URL}' ..."
rm -rf ${CLBLAS_SRC_DIR}
git clone ${CLBLAS_URL} --no-checkout ${CLBLAS_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning clBLAS from '${CLBLAS_URL}' failed!"
  exit 1
fi

echo ""
echo "Checking out the '${CLBLAS_TAG}' release of clBLAS ..."
cd ${CLBLAS_SRC_DIR}
git checkout tags/${CLBLAS_TAG} -b ${CLBLAS_TAG}
if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${CLBLAS_TAG}' release of clBLAS failed!"
  exit 1
fi

echo ""
echo "Patching the '${CLBLAS_TAG}' release of clBLAS ..."
cd ${CLBLAS_SRC_DIR}
patch -p1 < ${CLBLAS_PATCH_PATH}
if [ "${?}" != "0" ] ; then
  echo "Error: Patching the '${CLBLAS_TAG}' release of clBLAS failed!"
  exit 1
fi

echo ""
echo "Building the '${CLBLAS_TAG}' release of clBLAS ..."
rm -rf ${CLBLAS_OBJ_DIR}
mkdir -p ${CLBLAS_OBJ_DIR}
cd ${CLBLAS_OBJ_DIR}
cmake ${CLBLAS_SRC_DIR}/src \
  -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
  -DBUILD_TEST=OFF \
  -DSUFFIX_LIB=/ \
  -DCMAKE_C_COMPILER=${CK_CC} -DCMAKE_CXX_COMPILER=${CK_CXX} \
  -DOPENCL_LIBRARIES:FILEPATH=${CK_ENV_LIB_OPENCL_LIB}/${CK_ENV_LIB_OPENCL_DYNAMIC_NAME} \
  -DCMAKE_INSTALL_PREFIX:PATH=${CLBLAS_INSTALL_DIR}
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} install
if [ "${?}" != "0" ] ; then
  echo "Error: Building the '${CLBLAS_TAG}' release of clBLAS failed!"
  exit 1
fi
