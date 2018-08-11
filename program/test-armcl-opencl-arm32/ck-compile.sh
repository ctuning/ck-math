#!/bin/sh

# Collective Knowledge (program)
#
# See CK LICENSE.txt for licensing details
# See CK COPYRIGHT.txt for copyright details
#
# Developer: Grigori Fursin, Grigori.Fursin@cTuning.org
#            Flavio Vella, dividiti


CUR_PATH=${PWD}

cd ${CK_ENV_LIB_ARMCL_SRC}


rm -rf tests/validation_old

XOS=""
if [ "$OS" != "" ] ; then
   XOS="os=${OS}"
fi

XARCH=""
if [ "$ARCH" != "" ] ; then
   XARCH="arch=${ARCH}"
fi

scons Werror=${WERROR} -j${J} debug=${DEBUG} timers=${TIMERS} embed_kernels=${EMBED_KERNELS} examples=${EXAMPLES} \
      neon=${NEON} \
      opencl=${OPENCL} \
      openmp=${OPENMP} \
      cppthreads=${CPPTHREADS} \
      pmu=${PMU} \
      mali=${MALI} \
      validation_tests=${VALIDATION_TESTS} \
      benchmark_tests=${BENCHMARK_TESTS} \
      ${XOS} ${XARCH} \
      build=${BUILD} extra_cxx_flags="${EXTRA_CXX_FLAGS}"

cd build/tests
cp -rf * ${CUR_PATH}

return 0
