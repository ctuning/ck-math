#! /bin/bash

#
# Installation script for CLBlast.
#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2015;
# - Anton Lokhmotov, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

export CLBLAST_SRC_DIR=${INSTALL_DIR}/src
export CLBLAST_OBJ_DIR=${INSTALL_DIR}/obj

echo ""
echo "Cloning CLBlast overlay from '${CLBLAST_URL}' ..."
rm -rf ${CLBLAST_SRC_DIR}
git clone ${CLBLAST_URL} --no-checkout ${CLBLAST_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning CLBlast overlay from '${CLBLAST_URL}' failed!"
  exit 1
fi

echo ""
echo "Checking out the '${CLBLAST_BRANCH}' branch of CLBlast overlay ..."
cd ${CLBLAST_SRC_DIR}
git checkout ${CLBLAST_BRANCH}
if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${CLBLAST_BRANCH}' branch of CLBlast overlay failed!"
  exit 1
fi

echo ""
echo "Building the '${CLBLAST_BRANCH}' branch of CLBlast overlay ..."
rm -rf ${CLBLAST_OBJ_DIR}
mkdir -p ${CLBLAST_OBJ_DIR}
cd ${CLBLAST_OBJ_DIR}
cmake ${CLBLAST_SRC_DIR} -DCMAKE_OBJ_TYPE=Release \
  -DCMAKE_C_COMPILER=${CK_CC} -DCMAKE_CXX_COMPILER=${CK_CXX} \
  -DOPENCL_LIBRARIES:FILEPATH=${CK_ENV_LIB_OPENCL_LIB}/${CK_ENV_LIB_OPENCL_DYNAMIC_NAME} \
  -DOPENCL_INCLUDE_DIRS:PATH=${CK_ENV_LIB_OPENCL_INCLUDE} \
  -DCMAKE_PREFIX_PATH:PATH=${CK_ENV_LIB_CLBLAST} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR}
make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} install
if [ "${?}" != "0" ] ; then
  echo "Error: Building the '${CLBLAST_BRANCH}' branch of CLBlast overlay failed!"
  exit 1
fi

echo ""
echo "Creating symbolic links to ${CK_ENV_LIB_CLBLAST} ..."
ln -s ${CK_ENV_LIB_CLBLAST_LIB}/${CK_ENV_LIB_CLBLAST_DYNAMIC_NAME} \
      ${INSTALL_DIR}/lib/${CK_ENV_LIB_CLBLAST_DYNAMIC_NAME}
ln -s ${CK_ENV_LIB_CLBLAST_INCLUDE} \
      ${INSTALL_DIR}/include
if [ "${?}" != "0" ] ; then
  echo "Error: Creating symbolic links to '${CK_ENV_LIB_CLBLAST}' failed!"
  exit 1
fi
