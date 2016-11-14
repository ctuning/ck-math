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

################################################################################
echo ""
echo "Cloning clBLAS from '${CLBLAS_URL}' ..."

rm -rf ${CLBLAS_SRC_DIR}

git clone ${CLBLAS_URL} ${CLBLAS_SRC_DIR}

if [ "${?}" != "0" ] ; then
  echo "Error: Cloning clBLAS from '${CLBLAS_URL}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Patching the '${CLBLAS_TAG}' release of clBLAS ..."
cd ${CLBLAS_SRC_DIR}
patch -p1 < ${CLBLAS_PATCH_PATH}
if [ "${?}" != "0" ] ; then
  echo "Error: Patching the '${CLBLAS_TAG}' release of clBLAS failed!"
  exit 1
fi

################################################################################
echo ""
echo "Configuring ..."

rm -rf ${CLBLAS_OBJ_DIR}
mkdir -p ${CLBLAS_OBJ_DIR}
cd ${CLBLAS_OBJ_DIR}

cmake ${CLBLAS_SRC_DIR}/src \
  -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
  -DBUILD_TEST=OFF \
  -DSUFFIX_LIB=/ \
  -DBoost_ADDITIONAL_VERSIONS="1.62" \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DBOOST_ROOT=${CK_ENV_LIB_BOOST} \
  -DBOOST_INCLUDEDIR="${CK_ENV_LIB_BOOST_INCLUDE}" \
  -DBOOST_LIBRARYDIR="${CK_ENV_LIB_BOOST_LIB}" \
  -DBoost_INCLUDE_DIR="${CK_ENV_LIB_BOOST_INCLUDE}" \
  -DBoost_LIBRARY_DIR="${CK_ENV_LIB_BOOST_LIB}" \
  -DCMAKE_C_COMPILER="${CK_CC_PATH_FOR_CMAKE}" \
  -DCMAKE_CXX_COMPILER="${CK_CXX_PATH_FOR_CMAKE}" \
  -DCMAKE_C_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE}" \
  -DCMAKE_CXX_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE}" \
  -DOPENCL_ROOT=${CK_ENV_LIB_OPENCL} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR}

#  -DOPENCL_LIBRARIES:FILEPATH=${CK_ENV_LIB_OPENCL_LIB}/${CK_ENV_LIB_OPENCL_DYNAMIC_NAME} \

if [ "${?}" != "0" ] ; then
  echo "Error: cmake failed!"
  exit 1
fi

################################################################################
echo ""
echo "Building ..."

make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} install
if [ "${?}" != "0" ] ; then
  echo "Error: Building the '${CLBLAS_TAG}' release of clBLAS failed!"
  exit 1
fi
