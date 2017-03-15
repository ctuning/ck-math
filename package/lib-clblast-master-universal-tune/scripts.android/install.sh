#! /bin/bash

#
# Installation script.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, grigori.fursin@cTuning.org, 2017
# - Anton Lokhmotov, anton@dividiti.com, 2017
#

export CK_CMAKE_EXTRA="${CK_CMAKE_EXTRA} \
 -DOPENCL_ROOT=${CK_ENV_LIB_OPENCL} \
 -DOPENCL_LIBRARIES=${CK_ENV_LIB_OPENCL_LIB}/libOpenCL.so \
 -DOPENCL_INCLUDE_DIRS=${CK_ENV_LIB_OPENCL_INCLUDE} \
 -DTUNERS=ON -DCLTUNE_ROOT=${CK_ENV_TOOL_CLTUNE} \
 -DSAMPLES=ON \
 -DANDROID=ON"

return 0
