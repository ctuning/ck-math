#! /bin/bash

#
# Installation script for CLBlast overlay.
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
export CLBLAST_LIB_DIR=${INSTALL_DIR}/lib
export CLBLAST_INC_DIR=${INSTALL_DIR}/include

echo ""
echo "Cleaning previously installed CLBlast overlay in '${INSTALL_DIR}' ..."
rm -rf ${CLBLAST_OBJ_DIR}
rm -rf ${CLBLAST_SRC_DIR}
rm -rf ${CLBLAST_LIB_DIR}
rm -rf ${CLBLAST_INC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cleaning previously installed CLBlast overlay in '${INSTALL_DIR}'!"
  exit 1
fi

echo ""
echo "Cloning CLBlast overlay from '${CLBLAST_URL}' ..."
git clone ${CLBLAST_URL} --no-checkout ${CLBLAST_SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning CLBlast overlay from '${CLBLAST_URL}' failed!"
  exit 1
fi

echo ""
echo "Checking out the '${CLBLAST_BRANCH}' branch of CLBlast overlay ..."
cd ${CLBLAST_SRC_DIR} && git checkout ${CLBLAST_BRANCH}
if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${CLBLAST_BRANCH}' branch of CLBlast overlay failed!"
  exit 1
fi

echo ""
echo "Building the '${CLBLAST_BRANCH}' branch of CLBlast overlay ..."
mkdir -p ${CLBLAST_OBJ_DIR} && cd ${CLBLAST_OBJ_DIR}
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
ln -sf ${CK_ENV_LIB_CLBLAST_LIB}/${CK_ENV_LIB_CLBLAST_DYNAMIC_NAME} \
       ${CLBLAST_LIB_DIR}/${CK_ENV_LIB_CLBLAST_DYNAMIC_NAME}
ln -sf ${CK_ENV_LIB_CLBLAST_INCLUDE} \
       ${CLBLAST_INC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Creating symbolic links to '${CK_ENV_LIB_CLBLAST}' failed!"
  exit 1
fi
