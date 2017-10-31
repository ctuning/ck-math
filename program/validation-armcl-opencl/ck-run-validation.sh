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
echo "Running original ArmCL validation with --seed=${SEED} and --filter='${FILTER}' ..."

echo ""

export LD_LIBRARY_PATH=${CK_ENV_LIB_ARMCL_SRC}/build:${LD_LIBRARY_PATH}

./arm_compute_validation $1 --error-on-missing-assets \
  --seed=${SEED} --filter=${FILTER}

echo ""

# --env.FILTER='CL/SoftmaxLayer/Float/FP\\d\\d/RunSmall@Shape=633x11x3x5'

#------------------------------------------------------------------------------
return 0
