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
#

# ******************************************************************************

echo "Installing into ... \`${INSTALL_DIR}\`"

mkdir -p ${INSTALL_DIR}/install
mkdir -p ${INSTALL_DIR}/install/lib
mkdir -p ${INSTALL_DIR}/install/include

mkdir -p ${INSTALL_DIR}/src
mkdir -p ${INSTALL_DIR}/src/obj
cd ${INSTALL_DIR}/src/obj

# ******************************************************************************

echo ""
echo "Building static library ..."
echo ""

CK_TARGET_FILE=${CK_TARGET_LIB}${CK_LIB_EXT}
rm -f ${CK_TARGET_FILE}

echo "${CK_CXX} ${CK_COMPILER_FLAGS_OBLIGATORY} ${CK_FLAGS_STATIC_LIB} ${CK_FLAGS_CREATE_OBJ} ${CK_CXXFLAGS} ${CK_SRC_FILES} ${CK_FLAG_PREFIX_INCLUDE}.."
echo ""

${CK_CXX} ${CK_COMPILER_FLAGS_OBLIGATORY} ${CK_FLAGS_STATIC_LIB} ${CK_FLAGS_CREATE_OBJ} ${CK_CXXFLAGS} ${CK_SRC_FILES} ${CK_FLAG_PREFIX_INCLUDE}..
if [ "${?}" != "0" ] ; then
  echo ""
  echo "Building static library failed!"
  exit 1
fi

echo "${CK_LB} ${CK_LB_OUTPUT}${CK_TARGET_FILE} ${CK_OBJ_FILES}"
echo ""

${CK_LB} ${CK_LB_OUTPUT}${CK_TARGET_FILE} ${CK_OBJ_FILES}
if [ "${?}" != "0" ] ; then
  echo ""
  echo "Building static library failed!"
  exit 1
fi

cp -f ${CK_TARGET_FILE} ${INSTALL_DIR}/install/lib
if [ "${?}" != "0" ] ; then
  echo ""
  echo "Copying static library failed"
  exit 1
fi

# ******************************************************************************

CK_TARGET_FILE_D=${CK_TARGET_LIB}${CK_DLL_EXT}
if [ "${CK_BARE_METAL}" != "on" ] ; then
  echo ""
  echo "Building dynamic library ..."
  echo ""

  rm -f $CK_TARGET_FILE_D

  echo "${CK_CXX} ${CK_COMPILER_FLAGS_OBLIGATORY} ${CK_FLAGS_DLL} ${CK_CXXFLAGS} ${CK_SRC_FILES} ${CK_FLAG_PREFIX_INCLUDE}.. ${CK_FLAGS_OUTPUT}${CK_TARGET_FILE_D} ${CK_FLAGS_DLL_EXTRA} ${CK_LD_FLAGS_MISC} ${CK_LD_FLAGS_EXTRA} ${CK_LFLAGS}"
  ${CK_CXX} ${CK_COMPILER_FLAGS_OBLIGATORY} ${CK_FLAGS_DLL} ${CK_CXXFLAGS} ${CK_SRC_FILES} ${CK_FLAG_PREFIX_INCLUDE}.. ${CK_FLAGS_OUTPUT}${CK_TARGET_FILE_D} ${CK_FLAGS_DLL_EXTRA} ${CK_LD_FLAGS_MISC} ${CK_LD_FLAGS_EXTRA} ${CK_LFLAGS}
  if [ "${?}" != "0" ] ; then
    echo ""
    echo "Building dynamic library failed!"
    exit 1
  fi

  cp -f $CK_TARGET_FILE_D ${INSTALL_DIR}/install/lib
  if [ "${?}" != "0" ] ; then
    echo ""
    echo "Copying dynamic library failed!"
    exit 1
  fi
fi

# ******************************************************************************

echo ""
echo "Copying include headers ..."
echo ""

cp -rf ${INSTALL_DIR}/src/arm_compute ${INSTALL_DIR}/install/include/arm_compute
cp -rf ${INSTALL_DIR}/src/tests/ ${INSTALL_DIR}/install/include/arm_compute
if [ "${?}" != "0" ] ; then
  echo ""
  echo "Copying include headers failed!"
  exit 1
fi

exit 0
