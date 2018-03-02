#ifdef XOPENME
#include <xopenme.h>
#endif

#define ARM_COMPUTE_CL /* So that OpenCL exceptions get caught too */

#include "arm_compute/core/Types.h"
#include <arm_compute/core/Helpers.h>
#include <arm_compute/core/ITensor.h>
#include "arm_compute/core/CL/CLKernelLibrary.h"

#include <arm_compute/runtime/Tensor.h>
#include "arm_compute/runtime/CL/CLFunctions.h"
#include "arm_compute/runtime/CL/CLScheduler.h"

#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>

#include <cctype>
#include <cerrno>
#include <iomanip>
#include <string>
#include <sys/time.h>

using namespace arm_compute;

# define MYTIMER2 struct timeval
static MYTIMER2 before, after;
static double total_time;

int main( int argc, char *argv[] )
{
  long repetitions = 10;
  long r = 0;

  // (MM, MN, MK) come from compiler options (see .cm/meta)
  unsigned int m=MM;
  unsigned int n=MN;
  unsigned int k=MK;
  if (getenv("CK_CLBLAST_MSIZE")!=NULL) m=atol(getenv("CK_CLBLAST_MSIZE"));
  if (getenv("CK_CLBLAST_NSIZE")!=NULL) n=atol(getenv("CK_CLBLAST_NSIZE"));
  if (getenv("CK_CLBLAST_KSIZE")!=NULL) k=atol(getenv("CK_CLBLAST_KSIZE"));
  if (getenv("CK_CLBLAST_ITERATIONS")!=NULL) repetitions=atol(getenv("CK_CLBLAST_ITERATIONS"));

  const TensorShape AShape(k,m);
  const TensorShape BShape(n,k);
  TensorShape OShape(n,m);

  CLTensor ATensor;
  CLTensor BTensor;
  CLTensor OTensor;
  CLScheduler::get().default_init();

  const char* kernel_path = getenv("CK_ENV_LIB_ARMCL_CL_KERNELS");
  if (NULL != kernel_path) {
    CLKernelLibrary::get().set_kernel_path(kernel_path);
  }

  ATensor.allocator()->init(TensorInfo(AShape,Format::F32));
  BTensor.allocator()->init(TensorInfo(BShape,Format::F32));
  OTensor.allocator()->init(TensorInfo(OShape,Format::F32));

  CLGEMM gemm;
  gemm.configure(&ATensor, &BTensor, NULL, &OTensor, 2.0f, 2.0f);

  ATensor.allocator()->allocate();
  BTensor.allocator()->allocate();
  OTensor.allocator()->allocate();

  double min_time = 1e12;
  printf("NUM_REPETITIONS = %lu\n", repetitions);
  for(r = 0; r < repetitions; ++r) {
    gettimeofday(&before, NULL);
    gemm.run();
    CLScheduler::get().sync();
    gettimeofday(&after, NULL);
    double delta = (after.tv_sec - before.tv_sec) + 1e-6*(after.tv_usec - before.tv_usec);
    if(delta < min_time) min_time = delta;
    printf("TIME_REPETITION %ld = %lf\n", r, delta);
    total_time += delta;
  }
  double flops = 2.0*m*n*k;
  double gflops = 1e-9 * flops;
  double avg_time = total_time / repetitions;
  double avg_gflops_per_sec = gflops / avg_time;
  double max_gflops_per_sec = gflops / min_time;
  printf("M = %u\nN = %u\nK = %u\n", m, n, k);
  printf("TIME_AVG = %lf\n", avg_time);
  printf("TIME_MIN = %lf\n", min_time);
  printf("GFLOPS_AVG = %lf\n", avg_gflops_per_sec);
  printf("GFLOPS_MAX = %lf\n", max_gflops_per_sec);
  printf("STATUS = %d\n", 0);

  printf("------------- CLBLAST-STYLE_OUTPUT\n");
  printf("m = %u\nn = %u\nk = %u\n", m, n, k);
  printf("ms_1 = %lf\n", avg_time*1000);
  printf("GFLOPS_1 = %lf\n", avg_gflops_per_sec);

  return 0;
}
