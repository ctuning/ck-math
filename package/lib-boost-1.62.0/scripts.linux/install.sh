#! /bin/bash

#
# Extra installation script
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2016-2017
# - Anton Lokhmotov, 2017, 2020
# - Leo Gordon, 2018
#


if [ "${CK_COMPILER_TOOLCHAIN_NAME}" != "" ] ; then
  TOOLCHAIN=$CK_COMPILER_TOOLCHAIN_NAME
else
  TOOLCHAIN=gcc
fi

FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY=''

    # on a Mac:
if [ "$CK_DLL_EXT" == ".dylib" ]
then
    TOOLCHAIN=darwin
    if [ -n "$CK_ENV_COMPILER_LLVM_SET" ]
    then
        FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY="cxxflags=\"${CK_CXX_COMPILER_STDLIB}\" linkflags=\"${CK_CXX_COMPILER_STDLIB}\""
    elif [ -n "$CK_ENV_COMPILER_GCC_SET" ]
    then
        FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY='cxxflags="-std=gnu++0x"'
    fi
fi

BOOST_B2_LINK=""
if [ "${BOOST_STATIC}" == "yes" ] && [ "${BOOST_SHARED}" == "yes" ]; then
  BOOST_B2_LINK="link=static,shared"
elif [ "${BOOST_STATIC}" == "yes" ]; then
  BOOST_B2_LINK="link=static"
elif [ "${BOOST_SHARED}" == "yes" ]; then
  BOOST_B2_LINK="link=shared"
fi

############################################################
cd ${INSTALL_DIR}/${PACKAGE_SUB_DIR1}
./bootstrap.sh --with-toolset=${TOOLCHAIN} ${CK_ENV_COMPILER_PYTHON_FILE:+"--with-python=${CK_ENV_COMPILER_PYTHON_FILE}"} ${BOOST_WITHOUT_PYTHON:+"--without-libraries=python"}
if [ "${?}" != "0" ] ; then
  echo "Error: bootstrap failed!"
  exit 1
fi

############################################################
echo ""
echo "Building Boost (can take a long time) ..."

export BOOST_BUILD_PATH=$INSTALL_DIR/install

if [ "$TOOLCHAIN" != "intel-linux" ]
then
    USER_CONFIG_FILE=${INSTALL_DIR}/${PACKAGE_SUB_DIR1}/tools/build/src/user-config.jam
    echo "using ${TOOLCHAIN} : ${CK_COMPILER_VERSION} : ${CK_CXX_FULL_PATH} : -fPIC ${CK_CXX_FLAGS_FOR_CMAKE} ${EXTRA_FLAGS} -DNO_BZIP2 ;" > $USER_CONFIG_FILE
fi

./b2 install -j${CK_HOST_CPU_NUMBER_OF_PROCESSORS} toolset=${TOOLCHAIN} address-model=${CK_TARGET_CPU_BITS} $FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY --debug-configuration --prefix=${BOOST_BUILD_PATH} ${BOOST_B2_LINK} ${BOOST_B2_FLAGS} ${BOOST_B2_EXTRA_FLAGS}

if [ "${?}" != "0" ] ; then
  echo "Error: b2 make failed!"
  exit 1
fi

return 0
