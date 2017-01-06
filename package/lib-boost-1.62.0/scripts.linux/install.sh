#! /bin/bash

#
# Extra installation script
#
# See CK LICENSE.txt for licensing details.
# See CK Copyright.txt for copyright details.
#
# Developer(s): Grigori Fursin, 2016-2017
#

############################################################
cd ${INSTALL_DIR}/${PACKAGE_SUB_DIR1}
./bootstrap.sh
if [ "${?}" != "0" ] ; then
  echo "Error: cmake failed!"
  exit 1
fi

############################################################
echo ""
echo "Building (can be very long) ..."

TOOLCHAIN=gcc
if [ "${CK_COMPILER_TOOLCHAIN_NAME}" != "" ] ; then
  TOOLCHAIN=$CK_COMPILER_TOOLCHAIN_NAME
fi

export BOOST_BUILD_PATH=$INSTALL_DIR/install
echo "using ${TOOLCHAIN} : : ${CK_CXX} ${CK_CXX_FLAGS_FOR_CMAKE} ${EXTRA_FLAGS} -DNO_BZIP2 ;" > $BOOST_BUILD_PATH/user-config.jam

./b2 install toolset=${TOOLCHAIN} -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} --prefix=${BOOST_BUILD_PATH}
if [ "${?}" != "0" ] ; then
  echo "Error: b2 make failed!"
  exit 1
fi

return 0
