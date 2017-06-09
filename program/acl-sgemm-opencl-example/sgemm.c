#ifdef XOPENME
#include <xopenme.h>
#endif

//#include <arm_compute/runtime/NEON/NEFunctions.h>

#define ARM_COMPUTE_CL /* So that OpenCL exceptions get caught too */
#include "arm_compute/core/Types.h"
#include "arm_compute/runtime/CL/CLFunctions.h"
#include "arm_compute/runtime/CL/CLScheduler.h"
#include "test_helpers/Utils.h"



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
using namespace test_helpers;
# define MYTIMER2 struct timeval
static MYTIMER2 before, after;
static double secs;


int main(void)
{
  long r=0;
  long runs_max=10;
  int ct_return=0;

  const unsigned int m=MM;
  const unsigned int n=MN;
  const unsigned int k=MK;

  const TensorShape AShape(k,m);
  const TensorShape BShape(n,k);
  TensorShape OShape(n,m);

  CLTensor ATensor;
  CLTensor BTensor;
  CLTensor OTensor;
  CLScheduler::get().default_init();

  ATensor.allocator()->init(TensorInfo(AShape,Format::F32));
  BTensor.allocator()->init(TensorInfo(BShape,Format::F32));
  OTensor.allocator()->init(TensorInfo(OShape,Format::F32));
 
  CLGEMM gemm;
  gemm.configure(&ATensor, &BTensor, NULL, &OTensor, 1.0f, 0.0f);
//  gemm.configure(A, B, NULL, O, 1.0, 0.0);



  //gemm.configure(&A,&B,NULL,&O,1.0,1.0);
  ATensor.allocator()->allocate();
  BTensor.allocator()->allocate();
  OTensor.allocator()->allocate();
  CLScheduler::get().default_init();

  if (getenv("RUNS")!=NULL) runs_max=atol(getenv("RUNS"));
  for (r=0; r< runs_max; r++){
    gettimeofday(&before, NULL); 
    gemm.run();
    CLScheduler::get().sync();
    gettimeofday(&after, NULL);
    secs += (after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec)/1000000.0;

  }
  double avg_time = secs / runs_max;
  double ops=m*n*k*2/avg_time;
  double gops= ops/(1000000000);
  printf("Matrix Size = %u * %u * %u avg time = %lf over %lu repetions\n", m,n,k,avg_time, runs_max);
  printf("GFLOPS = %lf\n", gops);


  return 0;
}
