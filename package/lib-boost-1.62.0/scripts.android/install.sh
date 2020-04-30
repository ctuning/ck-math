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

#  Check extra stuff

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

export BOOST_BUILD_PATH=${INSTALL_DIR}/install

############################################################
echo ""
echo "Building Boost (can take a long time) ..."


if [ -d "$BOOST_BUILD_PATH" ] ; then
  rm -rf "$BOOST_BUILD_PATH"
fi

mkdir "$BOOST_BUILD_PATH"

TOOLCHAIN=gcc
if [ "${CK_COMPILER_TOOLCHAIN_NAME}" != "" ] ; then
  TOOLCHAIN=$CK_COMPILER_TOOLCHAIN_NAME
fi

BOOST_B2_LINK=""
if [ "$BOOST_SHARED" == "yes" ]; then
	BOOST_B2_LINK="link=static,shared hardcode-dll-paths=true dll-path=\"${BOOST_BUILD_PATH}/lib\""
	#BOOST_B2_LINK="link=static,shared hardcode-dll-paths=false"
elif [ "$BOOST_STATIC" == "yes" ]; then
	BOOST_B2_LINK="link=static"
fi

if [ -n "$CK_ENV_STANDALONE_TOOLCHAIN_SET" ]; then
#  echo "using clang : ${CK_ENV_STANDALONE_TOOLCHAIN_TARGET_ARCH} : ${CK_ENV_STANDALONE_TOOLCHAIN_ROOT}/bin/clang++ ;" > $BOOST_BUILD_PATH/user-config.jam
#  TOOLSET=clang-${CK_ENV_STANDALONE_TOOLCHAIN_TARGET_ARCH}
  echo "using clang : android : ${CK_ENV_STANDALONE_TOOLCHAIN_ROOT}/bin/clang++ ;" > $BOOST_BUILD_PATH/user-config.jam
  TOOLSET=clang-android
else
  echo "using ${TOOLCHAIN} : ${CK_ANDROID_NDK_ARCH} : ${CK_CXX} ${CK_COMPILER_FLAG_CPP14} -I${CK_ENV_LIB_STDCPP_INCLUDE} -I${CK_ENV_LIB_STDCPP_INCLUDE_EXTRA} ${CK_CXX_FLAGS_FOR_CMAKE} ${CK_CXX_FLAGS_ANDROID_TYPICAL} ${EXTRA_FLAGS} -DNO_BZIP2 ;" > $BOOST_BUILD_PATH/user-config.jam
  TOOLSET=${TOOLCHAIN}-${CK_ANDROID_NDK_ARCH}
fi

if [ "${BOOST_B2_FLAGS}" == "" ] ; then
  BOOST_B2_FLAGS=--without-mpi
fi

set

./b2 install -j${CK_HOST_CPU_NUMBER_OF_PROCESSORS} toolset=${TOOLSET} target-os=android threading=multi address-model=${CK_TARGET_CPU_BITS} --prefix=${BOOST_BUILD_PATH} ${BOOST_B2_LINK} ${BOOST_B2_FLAGS} ${BOOST_B2_EXTRA_FLAGS}
# Ignore exit since some libs are not supported for Android ...
#if [ "${?}" != "0" ] ; then
#  echo "Error: b2 make failed!"
#  exit 1
#fi

return 0
