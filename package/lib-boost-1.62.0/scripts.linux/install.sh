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
# - Leo Gordon, 2018


if [ "${CK_COMPILER_TOOLCHAIN_NAME}" != "" ] ; then
  TOOLSET=$CK_COMPILER_TOOLCHAIN_NAME
else
  TOOLSET=gcc
fi

FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY=''

    # on a Mac:
if [ "$CK_DLL_EXT" == ".dylib" ]
then
    TOOLSET=darwin
    if [ -n "$CK_ENV_COMPILER_LLVM_SET" ]
    then
        FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY='cxxflags="-stdlib=libstdc++" linkflags="-stdlib=libstdc++"'
    elif [ -n "$CK_ENV_COMPILER_GCC_SET" ]
    then
        FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY='cxxflags="-std=gnu++0x"'
    fi
fi


############################################################
cd ${INSTALL_DIR}/${PACKAGE_SUB_DIR1}
./bootstrap.sh --with-toolset=${TOOLSET} ${CK_ENV_COMPILER_PYTHON_FILE:+"--with-python=${CK_ENV_COMPILER_PYTHON_FILE}"}
if [ "${?}" != "0" ] ; then
  echo "Error: bootstrap failed!"
  exit 1
fi

############################################################
echo ""
echo "Building Boost (can take a long time) ..."

export BOOST_BUILD_PATH=$INSTALL_DIR/install

if [ "$TOOLSET" != "intel-linux" ]
then
    USER_CONFIG_FILE=${INSTALL_DIR}/${PACKAGE_SUB_DIR1}/tools/build/src/user-config.jam
    echo "using ${TOOLSET} : ${CK_COMPILER_VERSION} : ${CK_CXX_FULL_PATH} : -fPIC ${CK_CXX_FLAGS_FOR_CMAKE} ${EXTRA_FLAGS} -DNO_BZIP2 ;" > $USER_CONFIG_FILE
fi

./b2 install -j${CK_HOST_CPU_NUMBER_OF_PROCESSORS} toolset=${TOOLSET} address-model=${CK_TARGET_CPU_BITS} $FLAGS_FOR_B2_FOR_LIB_COMPATIBILITY --debug-configuration --prefix=${BOOST_BUILD_PATH} ${BOOST_B2_FLAGS}

if [ "${?}" != "0" ] ; then
  echo "Error: b2 make failed!"
  exit 1
fi

return 0
