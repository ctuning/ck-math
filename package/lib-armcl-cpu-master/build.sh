#! /bin/bash

#
# Make script for CK libraries
# (depends on configured/installed compilers via CK)
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2015-2017
# - Anton Lokhmotov, 2017
# - Dmitry Savenko, 2017
#

# ******************************************************************************

mkdir -p ${INSTALL_DIR}/src/obj
cd ${INSTALL_DIR}/src/obj

${CK_MAKE} -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} -f ${ORIGINAL_PACKAGE_DIR}/Makefile $@

if [ "${?}" != "0" ] ; then
  echo "Error: ARMCL build failed ..."
  exit 1
fi

cd ..
rm -rf ../install/include
mkdir ../install/include
cp -rf arm_compute ../install/include
cp -rf tests ../install/include/arm_compute

exit 0
