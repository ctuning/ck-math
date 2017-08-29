#! /bin/bash

#
# Extra installation script
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2016-2017
# - Anton Lokhmotov, 2017
#

#  Check extra stuff

EXTRA_FLAGS=""
if [ "${CK_ARMEABI_V7A}" == "ON" ] ; then
  EXTRA_FLAGS="${EXTRA_FLAGS} -mfpu=neon"
fi

if [ "${CK_ARMEABI_V7A_HARD}" == "ON" ] ; then
  EXTRA_FLAGS="${EXTRA_FLAGS} -mfpu=vfpv3"
fi

############################################################
cd ${INSTALL_DIR}/${PACKAGE_SUB_DIR1}
./bootstrap.sh
if [ "${?}" != "0" ] ; then
  echo "Error: cmake failed!"
  exit 1
fi

############################################################
echo ""
echo "Building Boost (can take a long time) ..."

if [ -d ${INSTALL_DIR}/install ] ; then
  rm -rf ${INSTALL_DIR}/install
fi

mkdir ${INSTALL_DIR}/install

TOOLCHAIN=gcc
if [ "${CK_COMPILER_TOOLCHAIN_NAME}" != "" ] ; then
  TOOLCHAIN=${CK_COMPILER_TOOLCHAIN_NAME}
fi

export BOOST_BUILD_PATH=${INSTALL_DIR}/install
mkdir -p ${BOOST_BUILD_PATH}
echo "using ${TOOLCHAIN} : arm : ${CK_CXX} ${CK_CXX_FLAGS_FOR_CMAKE} ${CK_CXX_FLAGS_ANDROID_TYPICAL} ${EXTRA_FLAGS} -DNO_BZIP2 ;" > ${BOOST_BUILD_PATH}/user-config.jam

./b2 install toolset=${TOOLCHAIN}-arm target-os=android -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} link=static --without-mpi address-model=${CK_TARGET_CPU_BITS} --prefix=${BOOST_BUILD_PATH}
# Ignore exit since some libs are not supported for Android ...
#if [ "${?}" != "0" ] ; then
#  echo "Error: b2 make failed!"
#  exit 1
#fi

return 0
