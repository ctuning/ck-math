#! /bin/bash

#
# Extra installation script
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2016-2017
# - Anton Lokhmtoov, 2017
#

# Check extra stuff

EXTRA_FLAGS=""
if [ "${CK_ARMEABI_V7A}" == "ON" ] ; then
  EXTRA_FLAGS="$EXTRA_FLAGS -mfpu=neon"
fi

if [ "${CK_ARMEABI_V7A_HARD}" == "ON" ] ; then
  EXTRA_FLAGS="$EXTRA_FLAGS -mfpu=vfpv3"
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
  TOOLCHAIN=$CK_COMPILER_TOOLCHAIN_NAME
fi

export BOOST_BUILD_PATH=${INSTALL_DIR}/install
echo "using ${TOOLCHAIN} : arm : ${CK_CXX} ${CK_CXX_FLAGS_FOR_CMAKE} ${CK_CXX_FLAGS_ANDROID_TYPICAL} ${EXTRA_FLAGS} -DNO_BZIP2 ;" > $BOOST_BUILD_PATH/user-config.jam

# FIXME: specifying '--without-mpi' (as for package:lib-boost-1.64.0) results in:
# "error: both --with-<library> and --without-<library> specified".
./b2 install -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} address-model=${CK_TARGET_CPU_BITS} target-os=android \
  toolset=${TOOLCHAIN}-arm link=static define=BOOST_TEST_ALTERNATIVE_INIT_API \
  --with-program_options --with-test \
  --prefix=${BOOST_BUILD_PATH}

# Ignore exit since some libs are not supported for Android ...
#if [ "${?}" != "0" ] ; then
#  echo "Error: b2 make failed!"
#  exit 1
#fi

return 0
