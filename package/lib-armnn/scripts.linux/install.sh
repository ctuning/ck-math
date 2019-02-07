#!/bin/bash

#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Leo Gordon, 2018
#

# for example,
#   INSTALL_DIR     = "~/CK-TOOLS/lib-leveldb-1.20-llvm-5.0.0-macos-64"
#   PACKAGE_SUB_DIR = "leveldb-1.20"

ARMNN_SOURCE_DIR=$INSTALL_DIR/$PACKAGE_SUB_DIR
ARMCL_SOURCE_DIR=$INSTALL_DIR/ComputeLibrary/src

ARMNN_BUILD_DIR=$ARMNN_SOURCE_DIR/build
ARMNN_TARGET_DIR=$INSTALL_DIR/install
TF_PB_DIR=$INSTALL_DIR/generated_tf_pb_files

############################################################
echo ""
echo "Building ArmNN package in $INSTALL_DIR ..."
echo ""

set

############################################################
echo ""
echo "Generating Protobuf files from Tensorflow ..."
echo ""

rm -rf "${TF_PB_DIR}"
mkdir ${TF_PB_DIR}
cd ${CK_ENV_LIB_TF}/src
${ARMNN_SOURCE_DIR}/scripts/generate_tensorflow_protobuf.sh ${TF_PB_DIR} ${CK_ENV_LIB_PROTOBUF_HOST}

############################################################
echo ""
echo "Running cmake for ArmNN ..."
echo ""

rm -rf "${ARMNN_BUILD_DIR}"
mkdir ${ARMNN_BUILD_DIR}
cd ${ARMNN_BUILD_DIR}
cmake .. \
    -DARMCOMPUTE_ROOT=${ARMCL_SOURCE_DIR} \
    -DARMCOMPUTE_BUILD_DIR=${ARMCL_SOURCE_DIR}/build \
    -DBOOST_ROOT=$CK_ENV_LIB_BOOST \
    -DTF_GENERATED_SOURCES=${TF_PB_DIR} \
    -DBUILD_TF_PARSER=1 \
    -DPROTOBUF_ROOT=$CK_ENV_LIB_PROTOBUF_HOST \
    -DCMAKE_INSTALL_PREFIX=${ARMNN_TARGET_DIR}

make

make install

