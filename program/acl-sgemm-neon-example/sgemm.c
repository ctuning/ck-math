#ifdef XOPENME
#include <xopenme.h>
#endif

#include <arm_compute/runtime/NEON/NEFunctions.h>

#include <arm_compute/core/Helpers.h>
#include <arm_compute/core/ITensor.h>
#include <arm_compute/core/Types.h>
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

using namespace arm_compute;

int main(void)
{
  long ct_repeat=0;
  long ct_repeat_max=1;
  int ct_return=0;

  unsigned int m=MM;
  unsigned int n=MN;
  unsigned int k=MK;

  TensorShape AShape(k,m);
  TensorShape BShape(n,k);
  TensorShape OShape(n,m);

  Tensor ATensor;
  Tensor BTensor;
  Tensor OTensor;

  ATensor.allocator()->init(TensorInfo(AShape,Format::F32));
  BTensor.allocator()->init(TensorInfo(BShape,Format::F32));
  OTensor.allocator()->init(TensorInfo(OShape,Format::F32));

  NEGEMM gemm;

  gemm.configure(&ATensor,&BTensor,nullptr,&OTensor,1.0,0.0);

  ATensor.allocator()->allocate();
  BTensor.allocator()->allocate();
  OTensor.allocator()->allocate();

  if (getenv("CT_REPEAT_MAIN")!=NULL) ct_repeat_max=atol(getenv("CT_REPEAT_MAIN"));

#ifdef XOPENME
  xopenme_init(1,2);
  xopenme_clock_start(0);
#endif

  for (ct_repeat=0; ct_repeat<ct_repeat_max; ct_repeat++)
    gemm.run();

#ifdef XOPENME
  xopenme_clock_end(0);
  xopenme_dump_state();
  xopenme_finish();
#endif

  return 0;
}
