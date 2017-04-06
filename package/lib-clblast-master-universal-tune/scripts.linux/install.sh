#! /bin/bash

#
# Extra Installation script
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, grigori.fursin@cTuning.org, 2017
#

export CK_CMAKE_EXTRA="${CK_CMAKE_EXTRA} \
 -DOPENCL_LIBRARIES=${CK_ENV_LIB_OPENCL_LIB}/libOpenCL.so \
 -DTUNERS=ON \
 -DCLTUNE_ROOT:PATH=${CK_ENV_TOOL_CLTUNE} \
 -DSAMPLES=ON \
 -DCLIENTS=ON \
 -DANDROID=ON"

return 0
