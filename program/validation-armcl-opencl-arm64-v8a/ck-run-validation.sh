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
#

if [ ! -d "${CK_ENV_LIB_ARMCL_CL_KERNELS}" ]; then
  echo "ERROR: Directory \`${CK_ENV_LIB_ARMCL_CL_KERNELS}\' with OpenCL kernels does not exist!"
  exit 1
fi

echo ""
echo "Copying OpenCL kernels ..."
echo ""

rm -rf cl_kernels
mkdir cl_kernels
cp ${CK_ENV_LIB_ARMCL_CL_KERNELS}/* cl_kernels

echo ""
echo "Running original ArmCL validation ..."
echo ""

./arm_compute_validation $1 --filter=${FILTER}

return 0
