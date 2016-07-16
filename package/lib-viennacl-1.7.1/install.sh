#! /bin/bash

#
# Installation script for ViennaCL.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Anton Lokhmotov, anton@dividiti.com, 2016.
#

# PACKAGE_DIR
# INSTALL_DIR

export VIENNACL_SRC_DIR=${INSTALL_DIR}/src
export VIENNACL_OBJ_DIR=${INSTALL_DIR}/obj
export VIENNACL_LIB_DIR=${INSTALL_DIR}/lib
export VIENNACL_PATCH=${PACKAGE_DIR}/181.patch

################################################################################
echo ""
echo "Cloning ViennaCL from '${VIENNACL_URL}' ..."

rm -rf ${VIENNACL_SRC_DIR}

git clone ${VIENNACL_URL} --no-checkout ${VIENNACL_SRC_DIR}

if [ "${?}" != "0" ] ; then
  echo "Error: Cloning ViennaCL from '${VIENNACL_URL}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Checking out the '${VIENNACL_TAG}' release of ViennaCL ..."

cd ${VIENNACL_SRC_DIR}

git checkout tags/${VIENNACL_TAG} -b ${VIENNACL_TAG}

if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${VIENNACL_TAG}' release of ViennaCL failed!"
  exit 1
fi

################################################################################
echo ""
echo "Patching the '${VIENNACL_TAG}' release of ViennaCL ..."

cd ${VIENNACL_SRC_DIR}

patch -p1 < ${VIENNACL_PATCH}

if [ "${?}" != "0" ] ; then
  echo "Error: Patching the '${VIENNACL_TAG}' release of ViennaCL failed!"
  exit 1
fi

################################################################################
echo ""
echo "Configuring ViennaCL..."

rm -rf ${VIENNACL_OBJ_DIR}
mkdir  ${VIENNACL_OBJ_DIR}
cd ${VIENNACL_OBJ_DIR}

cmake ${VIENNACL_SRC_DIR} \
  -DBUILD_TESTING=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
#TODO: -DBOOSTPATH=xyz ?

if [ "$?" != "0" ]; then
  echo "Error: failed configuring ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi

################################################################################
echo ""
echo "Building ViennaCL..."

cmake --build ${VIENNACL_OBJ_DIR}
#make -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS}

if [ "$?" != "0" ]; then
  echo "Error: failed making ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi

################################################################################
echo ""
echo "Installing ViennaCL..."

cmake -P cmake_install.cmake
#make install

# Weirdly, the above command does not copy the library, so doing this manually...
mkdir -p ${VIENNACL_LIB_DIR}
cp -f ${VIENNACL_OBJ_DIR}/libviennacl/libviennacl.so ${VIENNACL_LIB_DIR}

if [ "$?" != "0" ]; then
  echo "Error: failed installing ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi
