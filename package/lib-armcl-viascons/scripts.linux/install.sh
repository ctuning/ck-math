#!/bin/bash

#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Leo Gordon, 2019
#

# for example,
#   INSTALL_DIR     = "lib-armcl-viascons-linux-64"
#   PACKAGE_SUB_DIR = "src"

ARMCL_SOURCE_DIR=$INSTALL_DIR/$PACKAGE_SUB_DIR

############################################################
echo ""
echo "Building ArmCL package in $INSTALL_DIR using scons in ${CK_HOST_CPU_NUMBER_OF_PROCESSORS:-UndefinedNumberOf} threads ..."
echo ""

cd ${ARMCL_SOURCE_DIR}
scons -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS:-1} arch=arm64-v8a extra_cxx_flags="-fPIC" benchmark_tests=0 validation_tests=0

