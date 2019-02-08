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
ARMNN_BUILD_DIR=$INSTALL_DIR/obj
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
echo "Running cmake for ArmNN with USE_OPENCL='${USE_OPENCL}' ..."
echo ""

if [ "$USE_OPENCL" == "ON" ] || [ "$USE_OPENCL" == "on" ] || [ "$USE_OPENCL" == "1" ]
then
    NUMERIC_USE_OPENCL=1
else
    NUMERIC_USE_OPENCL=0
fi

rm -rf "${ARMNN_BUILD_DIR}"
mkdir ${ARMNN_BUILD_DIR}
cd ${ARMNN_BUILD_DIR}
cmake ${ARMNN_SOURCE_DIR} \
    -DARMCOMPUTECL=${NUMERIC_USE_OPENCL} \
    -DARMCOMPUTE_ROOT=${CK_ENV_LIB_ARMCL} \
    -DARMCOMPUTE_BUILD_DIR=${CK_ENV_LIB_ARMCL}/build \
    -DBOOST_ROOT=$CK_ENV_LIB_BOOST \
    -DTF_GENERATED_SOURCES=${TF_PB_DIR} \
    -DBUILD_TF_PARSER=1 \
    -DPROTOBUF_ROOT=$CK_ENV_LIB_PROTOBUF_HOST \
    -DCMAKE_INSTALL_PREFIX=${ARMNN_TARGET_DIR}

