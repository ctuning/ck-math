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
git clone ${CLBLAST_URL} ${CLBLAST_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning CLBlast from '${CLBLAST_URL}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Building the '${CLBLAST_BRANCH}' branch of CLBlast ..."

rm -rf ${CLBLAST_BLD_DIR}

mkdir -p ${CLBLAST_BLD_DIR}
cd ${CLBLAST_BLD_DIR}

CK_TOOLCHAIN=android.toolchain.cmake
if [ "${CK_ENV_LIB_CRYSTAX_LIB}" != "" ] ; then
  CK_TOOLCHAIN=toolchain.cmake
fi

cmake -DCMAKE_TOOLCHAIN_FILE="${PACKAGE_DIR}/misc/${CK_TOOLCHAIN}" \
      -DANDROID_NDK="${CK_ANDROID_NDK_ROOT_DIR}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DANDROID_ABI="${CK_ANDROID_ABI}" \
      -DANDROID_NATIVE_API_LEVEL=${CK_ANDROID_API_LEVEL} \
      -DOPENCL_ROOT="${CK_ENV_LIB_OPENCL}" \
      -DOPENCL_LIBRARIES="${CK_ENV_LIB_OPENCL_LIB}/libOpenCL.so" \
      -DOPENCL_INCLUDE_DIRS="${CK_ENV_LIB_OPENCL_INCLUDE}" \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/install" \
      ../src

################################################################################
echo ""
echo "Building ..."

make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} install
if [ "${?}" != "0" ] ; then
  echo "Error: Building failed!"
  exit 1
fi
