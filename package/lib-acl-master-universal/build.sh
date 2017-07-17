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

mkdir -p ../install
mkdir -p ../install/lib

mkdir -p obj
cd obj

# ******************************************************************************

echo ""
echo "Building static library ..."
echo ""

CK_TARGET_FILE=${CK_TARGET_LIB}${CK_LIB_EXT}
rm -f $CK_TARGET_FILE

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

cp -f $CK_TARGET_FILE ../../install/lib
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

  cp -f $CK_TARGET_FILE_D ../../install/lib
  if [ "${?}" != "0" ] ; then
    echo ""
    echo "Copying dynamic library failed!"
    exit 1
  fi
fi

# ******************************************************************************

echo ""
echo "Copying include files ..."
echo ""

cd ..
rm -rf ../install/include
mkdir ../install/include
cp -rf arm_compute ../install/include/arm_compute
cp -rf test_helpers ../install/include/test_helpers

exit 0
