#! /bin/bash

#
# Installation script for clBLAS.
#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2015-2017;
# - Anton Lokhmotov, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

cd ${INSTALL_DIR}

############################################################
echo ""
echo "Cloning package from '${PACKAGE_URL}' ..."

rm -rf src
git clone ${PACKAGE_URL} src

if [ "${?}" != "0" ] ; then
  echo "Error: cloning package failed!"
  exit 1
fi

############################################################
echo ""
echo "Cleaning ..."

cd ${INSTALL_DIR}

############################################################
echo ""
echo "Executing cmake ..."

rm -rf obj
mkdir obj

# Check extra stuff
CMAKE_EXTRA=""
if [ "${CK_ARMEABI_V7A}" == "ON" ] ; then
  CMAKE_EXTRA="$CMAKE_EXTRA -DARMEABI_V7A=ON"
fi
if [ "${CK_ARMEABI_V7A_HARD}" == "ON" ] ; then
  CMAKE_EXTRA="$CMAKE_EXTRA -DARMEABI_V7A_HARD=ON"
fi

cd obj

cmake -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
      -DCMAKE_C_COMPILER="${CK_CC_PATH_FOR_CMAKE}" \
      -DCMAKE_C_FLAGS="${CK_CC_FLAGS_FOR_CMAKE} ${CK_CC_FLAGS_ANDROID_TYPICAL}" \
      -DCMAKE_CXX_COMPILER="${CK_CXX_PATH_FOR_CMAKE}" \
      -DCMAKE_CXX_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE} ${CK_CXX_FLAGS_ANDROID_TYPICAL}" \
      -DCMAKE_AR="${CK_AR_PATH_FOR_CMAKE}" \
      -DCMAKE_LINKER="${CK_LD_PATH_FOR_CMAKE}" \
      -DCMAKE_EXE_LINKER_FLAGS="${CK_LINKER_FLAGS_ANDROID_TYPICAL}" \
      -DCMAKE_EXE_LINKER_LIBS="${CK_LINKER_LIBS_ANDROID_TYPICAL}" \
      -DBUILD_ZLIB=ON \
      -DUSE_IPPICV=OFF \
      -DWITH_JPEG=ON \
      -DWITH_1394=OFF \
      -DBUILD_JPEG=ON \
      -DBUILD_PNG=ON \
      -DBUILD_TIFF=ON \
      -DWITH_CUDA=OFF \
      -DWITH_MATLAB=OFF \
      -DWITH_LAPACK=OFF \
      -DWITH_MKL=OFF \
      -DBUILD_ANDROID_EXAMPLES=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_DOCS=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DBUILD_TESTS=OFF \
      -DWITH_CAROTENE=OFF \
      -DANDROID=ON \
      -DANDROID_NDK="${CK_ANDROID_NDK_ROOT_DIR}" \
      -DANDROID_ABI="${CK_ANDROID_ABI}" \
      -DENABLE_NEON="${CK_CPU_ARM_NEON}" \
      -DENABLE_VFPV3=${CK_CPU_ARM_VFPV3} \
      -DANDROID_STL="gnustl_static" \
      -DANDROID_NATIVE_API_LEVEL=${CK_ANDROID_API_LEVEL} \
      -DANDROID_NDK_ABI_NAME=${CK_ANDROID_ABI} \
      -DCMAKE_SYSTEM="${CK_ANDROID_NDK_PLATFORM}" \
      -DCMAKE_SYSTEM_NAME="Android" \
      -DCMAKE_SYSTEM_VERSION="1" \
      -DCMAKE_SYSTEM_PROCESSOR="${CK_CMAKE_SYSTEM_PROCESSOR}" \
      -DCMAKE_CROSSCOMPILING="TRUE" \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/install" \
      ${CMAKE_EXTRA} \
      ../src

if [ "${?}" != "0" ] ; then
  echo "Error: cmake failed!"
  exit 1
fi

############################################################
echo ""
echo "Building package ..."

#make VERBOSE=1
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS}
if [ "${?}" != "0" ] ; then
  echo "Error: build failed!"
  exit 1
fi

############################################################
echo ""
echo "Installing package ..."

rm -rf install

make install/strip
if [ "${?}" != "0" ] ; then
  echo "Error: installation failed!"
  exit 1
fi

exit 0
