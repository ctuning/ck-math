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

CK_OPENMP=ON
if [ "${CK_HAS_OPENMP}" = "0"  ]; then
  CK_OPENMP=OFF
fi

export CK_CMAKE_EXTRA="${CK_CMAKE_EXTRA} \
 -DOPENCL_ROOT=${CK_ENV_LIB_OPENCL} \
 -DOPENCL_LIBRARIES=${CK_ENV_LIB_OPENCL_LIB}/libOpenCL.so \
 -DOPENCL_INCLUDE_DIRS=${CK_ENV_LIB_OPENCL_INCLUDE}"

return 0
