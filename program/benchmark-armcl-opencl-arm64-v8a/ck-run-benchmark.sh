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
echo "Running original ARMCL benchmark ..."
echo ""
echo "DEBUG"
echo $1
echo $FILTER
echo "DEBUG END"

if [ -z ${FILTER} ];then
    ./arm_compute_benchmark $1;
else 
    ./arm_compute_benchmark $1 --filter=${FILTER};
fi

return 0
