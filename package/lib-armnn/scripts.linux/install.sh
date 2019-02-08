#!/bin/bash

#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Leo Gordon, 2018
#

# for example,
#   INSTALL_DIR     = "lib-armnn-linux-64"
#   PACKAGE_SUB_DIR = "src"

ARMNN_SOURCE_DIR=$INSTALL_DIR/$PACKAGE_SUB_DIR
ARMCL_SOURCE_DIR=$INSTALL_DIR/ComputeLibrary/src

#ARMNN_BUILD_DIR=$ARMNN_SOURCE_DIR/build
ARMNN_BUILD_DIR=$INSTALL_DIR/obj
ARMNN_TARGET_DIR=$INSTALL_DIR/install
TF_PB_DIR=$INSTALL_DIR/generated_tf_pb_files

############################################################
echo ""
echo "Building ArmNN package in $INSTALL_DIR ..."
echo ""

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
cmake ${ARMNN_SOURCE_DIR} \
    -DARMCOMPUTE_ROOT=${ARMCL_SOURCE_DIR} \
    -DARMCOMPUTE_BUILD_DIR=${ARMCL_SOURCE_DIR}/build \
    -DBOOST_ROOT=$CK_ENV_LIB_BOOST \
    -DTF_GENERATED_SOURCES=${TF_PB_DIR} \
    -DBUILD_TF_PARSER=1 \
    -DPROTOBUF_ROOT=$CK_ENV_LIB_PROTOBUF_HOST \
    -DCMAKE_INSTALL_PREFIX=${ARMNN_TARGET_DIR}

