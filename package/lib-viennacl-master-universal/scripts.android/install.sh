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
 -DENABLE_OPENCL=${CK_INSTALL_ENABLE_OPENCL} \
 -DENABLE_OPENMP=${CK_OPENMP} \
 -DBOOSTPATH=${CK_ENV_LIB_BOOST} \
 -DBOOST_ROOT=${CK_ENV_LIB_BOOST_INCLUDE} \
 -DBoost_ADDITIONAL_VERSIONS=\"1.62\" \
 -DBoost_NO_SYSTEM_PATHS=ON \
 -DBOOST_ROOT=${CK_ENV_LIB_BOOST} \
 -DBOOST_INCLUDEDIR=\"${CK_ENV_LIB_BOOST_INCLUDE}\" \
 -DBOOST_LIBRARYDIR=\"${CK_ENV_LIB_BOOST_LIB}\" \
 -DBoost_INCLUDE_DIR=\"${CK_ENV_LIB_BOOST_INCLUDE}\" \
 -DBoost_LIBRARY_DIR=\"${CK_ENV_LIB_BOOST_LIB}\" \
 -DBOOSTPATH=${CK_ENV_LIB_BOOST}"

return 0
