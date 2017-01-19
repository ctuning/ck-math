#! /bin/bash

#
# Extra installation script
#
# See CK LICENSE.txt for licensing details.
# See CK Copyright.txt for copyright details.
#
# Developer(s): Grigori Fursin, 2016-2017
#

export CK_CMAKE_EXTRA="${CK_CMAKE_EXTRA} \
 -DOPENCL_LIBRARIES=${CK_ENV_LIB_OPENCL_LIB}/libOpenCL.so \
 -DOPENCL_INCLUDE_DIRS=${CK_ENV_LIB_OPENCL_INCLUDE} \
 -DVIENNACL_INCLUDE_DIR=${CK_ENV_LIB_VIENNACL_INCLUDE}"

return 0
