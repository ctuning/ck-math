#!/bin/sh

#
# Collective Knowledge (CK).
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developers:
# - Grigori Fursin, Grigori.Fursin@cTuning.org
# - Flavio Vella, flavio@dividiti.com
# - Anton Lokhmotov, anton@dividiti.com
#

export WORKING_DIR=`pwd`

#------------------------------------------------------------------------------
echo ""
echo "Copying OpenCL kernels from '${CK_ENV_LIB_ARMCL_CL_KERNELS}' to '${WORKING_DIR}' ..."

if [ ! -d "${CK_ENV_LIB_ARMCL_CL_KERNELS}" ]; then
  echo "ERROR: Directory '${CK_ENV_LIB_ARMCL_CL_KERNELS}' with OpenCL kernels does not exist!"
  exit 1
fi

rm -rf ${WORKING_DIR}/cl_kernels
cp -r ${CK_ENV_LIB_ARMCL_CL_KERNELS} ${WORKING_DIR}

#------------------------------------------------------------------------------
echo ""
echo "Benchmarking '${EXECUTABLE}' with args '${ARGS}' (0 - Neon, 1 - OpenCL, 2 - OpenCL tuner) ..."

export LD_LIBRARY_PATH=${CK_ENV_LIB_ARMCL_SRC}/build:${LD_LIBRARY_PATH}

${EXECUTABLE} --instruments=${INSTRUMENTS} --example_args=${ARGS} --iterations=${ITERATIONS}

echo ""

#------------------------------------------------------------------------------
return 0
