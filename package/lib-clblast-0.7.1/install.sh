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
export CLBLAST_BLD_LOG=${CLBLAST_BLD_DIR}/build.log

################################################################################
echo ""
echo "Cloning CLBlast from '${CLBLAST_URL}' ..."

rm -rf ${CLBLAST_SRC_DIR}
git clone ${CLBLAST_URL} --no-checkout ${CLBLAST_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning CLBlast from '${CLBLAST_URL}' failed!"
  exit 1
fi

################################################################################
if [ "${CLBLAST_TAG}" != "" ] ; then 
 echo ""
 echo "Checking out the '${CLBLAST_TAG}' release of CLBlast ..."
 cd ${CLBLAST_SRC_DIR}
 git checkout tags/${CLBLAST_TAG} -b ${CLBLAST_TAG}
 if [ "${?}" != "0" ] ; then
   echo "Error: Checking out the '${CLBLAST_TAG}' release of CLBlast failed!"
   exit 1
 fi
fi

################################################################################
echo
echo "Logging into '${CLBLAST_BLD_LOG}' ..."

rm -rf ${CLBLAST_BLD_DIR}; mkdir ${CLBLAST_BLD_DIR}
touch ${CLBLAST_BLD_LOG}; sleep 0.5

echo "** DATE **" >> ${CLBLAST_BLD_LOG}
date >> ${CLBLAST_BLD_LOG}

echo "** SET **" >> ${CLBLAST_BLD_LOG}
set >> ${CLBLAST_BLD_LOG}

################################################################################
echo ""
echo "Configuring the '${CLBLAST_TAG}' release of CLBlast ..."
echo "** CMAKE **" >> ${CLBLAST_BLD_LOG}

cd ${CLBLAST_BLD_DIR}
cmake ${CLBLAST_SRC_DIR} \
  -DCMAKE_BUILD_TYPE=${CK_ENV_CMAKE_BUILD_TYPE:-Release} \
  -DCMAKE_C_COMPILER=${CK_CC} -DCMAKE_CXX_COMPILER=${CK_CXX} \
  -DOPENCL_LIBRARIES:FILEPATH=${CK_ENV_LIB_OPENCL_LIB}/${CK_ENV_LIB_OPENCL_DYNAMIC_NAME} \
  -DOPENCL_INCLUDE_DIRS:PATH=${CK_ENV_LIB_OPENCL_INCLUDE} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR} \
  >>${CLBLAST_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Configuring the '${CLBLAST_TAG}' release of CLBlast failed!"
  exit 1
fi

################################################################################
echo ""
echo "Building the '${CLBLAST_TAG}' release of CLBlast ..."
echo "** MAKE **" >> ${CLBLAST_BLD_LOG}

cd ${CLBLAST_BLD_DIR}
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} install >>${CLBLAST_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Building the '${CLBLAST_TAG}' release of CLBlast failed!"
  exit 1
fi

################################################################################
echo ""
echo "Installing the '${CLBLAST_TAG}' release of CLBlast ..."
echo "** INSTALL **" >> ${CLBLAST_BLD_LOG}

cd ${CLBLAST_BLD_DIR}
make install >>${CLBLAST_BLD_LOG} 2>&1
if [ "${?}" != "0" ] ; then
  echo "Error: Installing the '${CLBLAST_TAG}' release of CLBlast failed!"
  exit 1
fi

###############################################################################
echo ""
echo "Installed CLBlast ${CLBLAST_TAG} into '${INSTALL_DIR}'."
