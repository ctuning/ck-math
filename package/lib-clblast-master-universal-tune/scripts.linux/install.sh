#! /bin/bash

#
# Extra installation script.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, grigori.fursin@cTuning.org, 2017
#

export CK_CMAKE_EXTRA="${CK_CMAKE_EXTRA} \
 -DOPENCL_LIBRARIES=${CK_ENV_LIB_OPENCL_LIB}/libOpenCL.so \
 -DTUNERS=${CLBLAST_TUNERS} \
 -DCLTUNE_ROOT:PATH=${CK_ENV_TOOL_CLTUNE} \
 -DSAMPLES=${CLBLAST_SAMPLES} \
 -DVERBOSE=${CLBLAST_VERBOSE} \
 -DCLIENTS=${CLBLAST_CLIENTS}"

return 0
