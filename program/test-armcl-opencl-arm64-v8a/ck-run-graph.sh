#!/bin/sh

# Collective Knowledge (program)
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developers:
# - Grigori Fursin, Grigori.Fursin@cTuning.org
# - Flavio Vella, flavio@dividiti.com
# - Anton Lokhmotov, anton@dividiti.com

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

export LD_LIBRARY_PATH=${CK_ENV_LIB_ARMCL_SRC}/build:${LD_LIBRARY_PATH}

# Target: 0 - Neon; 1 - OpenCL.
export ARM_COMPUTE_TARGET=1

${EXECUTABLE} ${ARM_COMPUTE_TARGET}

echo ""

#------------------------------------------------------------------------------
return 0
