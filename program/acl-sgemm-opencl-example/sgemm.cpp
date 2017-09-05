#ifdef XOPENME
#include <xopenme.h>
#endif

#define ARM_COMPUTE_CL /* So that OpenCL exceptions get caught too */

#include "arm_compute/core/CL/CLKernelLibrary.h"
#include "arm_compute/core/Types.h"
#include "arm_compute/runtime/CL/CLFunctions.h"
#include "arm_compute/runtime/CL/CLScheduler.h"
#include "arm_compute/tests/Utils.h"

#include <arm_compute/core/Helpers.h>
#include <arm_compute/core/ITensor.h>
#include <arm_compute/core/Validate.h>
#include <arm_compute/runtime/Tensor.h>

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
using namespace test;

# define MYTIMER2 struct timeval
static MYTIMER2 before, after;
static double secs;

int main( int argc, char *argv[] )
{

  long r=0;
  long runs_max=10;
  int ct_return=0;

  // (MM, MN, MK) come from compiler options (see .cm/meta)
  unsigned int m=MM;
  unsigned int n=MN;
  unsigned int k=MK;
  if (getenv("CK_CLBLAST_MSIZE")!=NULL) m=atol(getenv("CK_CLBLAST_MSIZE"));
  if (getenv("CK_CLBLAST_NSIZE")!=NULL) n=atol(getenv("CK_CLBLAST_NSIZE"));
  if (getenv("CK_CLBLAST_KSIZE")!=NULL) k=atol(getenv("CK_CLBLAST_KSIZE"));
  if (getenv("CK_CLBLAST_ITERATIONS")!=NULL) runs_max=atol(getenv("CK_CLBLAST_ITERATIONS"));

  const TensorShape AShape(k,m);
  const TensorShape BShape(n,k);
  TensorShape OShape(n,m);

  printf("tensors\n");

  CLTensor ATensor;
  CLTensor BTensor;
  CLTensor OTensor;
  CLScheduler::get().default_init();

  const char* kernel_path = getenv("CK_ENV_LIB_ACL_CL_KERNELS");
  if (NULL != kernel_path) {
    printf("hooray %s\n", kernel_path);
    CLKernelLibrary::get().set_kernel_path(kernel_path);
  } else {
    printf("n ofound kernel path\n");
  }

  printf("scheduler\n");

  ATensor.allocator()->init(TensorInfo(AShape,Format::F32));
  BTensor.allocator()->init(TensorInfo(BShape,Format::F32));
  OTensor.allocator()->init(TensorInfo(OShape,Format::F32));

  printf("alloc\n");

  CLGEMM gemm;
  gemm.configure(&ATensor, &BTensor, NULL, &OTensor, 2.0f, 2.0f);

  printf("gemm\n");

  ATensor.allocator()->allocate();
  BTensor.allocator()->allocate();
  OTensor.allocator()->allocate();

  printf("def_init\n");

//  if (getenv("RUNS")!=NULL) runs_max=atol(getenv("RUNS"));
  for (r=0; r< runs_max; r++) {
    gettimeofday(&before, NULL);
    gemm.run();
    CLScheduler::get().sync();
    gettimeofday(&after, NULL);
    printf("ROUND %d = %lf\n",r, ((after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec)/1000000.0));
    secs += (after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec)/1000000.0;
  }
  double avg_time = secs / runs_max;
  double ops=m*n*k*2/avg_time;
  double gops= ops/(1000000000);
  printf("M = %u\nN = %u\nK = %u\n", m, n, k);
  printf("AVG = %lf\nREPETITIONS = %lu\n", avg_time, runs_max);
  printf("GFLOPS = %lf\n", gops);
  printf("STATUS = %d\n", 0);

  printf("------------- CLBLAST-STYLE_OUTPUT\n");
  printf("m = %u\nn = %u\nk = %u\n", m, n, k);
  printf("ms_1 = %lf\n", avg_time*1000);
  printf("GFLOPS_1 = %lf\n", gops);

  return 0;
}
