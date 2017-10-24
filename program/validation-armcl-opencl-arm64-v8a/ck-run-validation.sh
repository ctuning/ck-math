#!/bin/sh

# Collective Knowledge (program)
#
# See CK LICENSE.txt for licensing details
# See CK COPYRIGHT.txt for copyright details
#
# Developer: Grigori Fursin, Grigori.Fursin@cTuning.org
#            Flavio Vella, dividiti
#

echo ""
echo "Copying CL kernels ..."
echo ""

rm -rf cl_kernels
mkdir cl_kernels
cp ${CK_ENV_LIB_ARMCL_CL_KERNELS}/* cl_kernels

echo ""
echo "Running original ARMCL validation ..."
echo ""

./arm_compute_validation $1 --filter=${FILTER}

return 0
