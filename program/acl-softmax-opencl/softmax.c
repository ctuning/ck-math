#ifdef XOPENME
#include <xopenme.h>
#endif

//#include <arm_compute/runtime/NEON/NEFunctions.h>

#define ARM_COMPUTE_CL /* So that OpenCL exceptions get caught too */
#include "arm_compute/core/Types.h"
#include "arm_compute/runtime/CL/CLFunctions.h"
#include "arm_compute/runtime/CL/CLScheduler.h"
#include "arm_compute/core/CL/CLKernelLibrary.h"

//#include "tests/Utils.h"



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
//using namespace test_helpers;
# define MYTIMER2 struct timeval
static MYTIMER2 before, after;
static double secs;
#define MYMAX 100
#define STEP 1 


int main( int argc, char *argv[] )
{
  int r=0;
/*data init to be replaced with ppm images*/
  unsigned int width  = 16;
  unsigned int height = 16;
  unsigned int nchan = 2;
  unsigned int seed = 42;
  
  if (getenv("CK_WIDTH")!=NULL)  width=atol(getenv("CK_WIDTH"));
  if (getenv("CK_HEIGHT")!=NULL)  height=atol(getenv("CK_HEIGHT"));
  if (getenv("CK_BSIZE")!=NULL)  nchan=atol(getenv("CK_BSIZE"));
  std::cout << "WIDTH, HEIGHT, BSIZE " << width << " " <<  height << " " << nchan << "\n";
  if (getenv("CK_SEED")!=NULL)  seed=atol(getenv("CK_SEED"));
  std::cout << "CK_SEED " << seed << "\n";
  srand(seed);
  

  const int rnd_max = 1000000;
  const int rnd_range = 2*rnd_max + 1;


  auto *src_data = new float[width * height * nchan];
  auto *dst_data = new float[width * height * nchan];
  for(unsigned int b = 0; b < nchan; b++){
     for(unsigned int h = 0; h < height; h++){
       for(unsigned int w = 0; w < width; w++){
         float r = static_cast <float> (-rnd_max +rand()%rnd_range) / (static_cast <float> (rnd_max));
//         printf("%f\n", r);
         src_data[b * (width * height) + h * width + w] = r; //replace with random fixed seed value
         dst_data[b * (width * height) + h * width + w] = 0;
       }
     }
   }


// end data init 


// OpenCL init
  CLScheduler::get().default_init();
  const char* kernel_path = getenv("CK_ENV_LIB_ACL_CL_KERNELS");
  if (NULL != kernel_path) {
    printf("%s\n",kernel_path);
    CLKernelLibrary::get().set_kernel_path(kernel_path);
    
  }

  CLTensor ATensor; //NETensor for Neon 
  CLTensor OTensor;

  TensorShape shape(width, height, nchan);
  ATensor.allocator()->init(TensorInfo(shape,  Format::F32));
  OTensor.allocator()->init(TensorInfo(shape,  Format::F32));
  
  //FILL TENSORS... easiest way is: create an iteretor 
  Window input_window;
  input_window.use_tensor_dimensions(ATensor.info());

  printf("Softmax kernel configuration\n");
  CLSoftmaxLayer softmax;
  softmax.configure(&ATensor,&OTensor);
  printf("END\n");
  printf("input:\n");
  for(unsigned int b = 0; b < nchan; b++){
     for(unsigned int h = 0; h < height; h++){
       for(unsigned int w = 0; w < width; w++){
         printf("%f ", src_data[b * (width * height) + h * width + w]);
       }
     }
   }
   printf("END input\n");


  //Data in/out
  ATensor.allocator()->allocate();
  OTensor.allocator()->allocate();

  ATensor.map();
  Iterator input_it(&ATensor, input_window);
  execute_window_loop(input_window, [&](const Coordinates & id){
#ifdef PRINT
    printf("%f\n", src_data[id.z() * (width * height) + id.y() * width + id.x()]);
#endif

    *reinterpret_cast<float *>(input_it.ptr()) = src_data[id.z() * (width * height) + id.y() * width + id.x()];
  },input_it);
  
  ATensor.unmap();
//Execution
  printf("Softmax kernel execution\n");
  gettimeofday(&before, NULL); 
  softmax.run();
  CLScheduler::get().sync();
  gettimeofday(&after, NULL);
  printf("END\n");

//Get output
  Window output_window;
  output_window.use_tensor_dimensions(OTensor.info());
  OTensor.map();
  Iterator output_it(&OTensor, output_window);
  execute_window_loop(output_window, [&](const Coordinates & id){
  dst_data[id.z() * (width * height) + id.y() * width + id.x()]= *reinterpret_cast<float*>(output_it.ptr());
#ifdef PRINT
  printf("%f\n", dst_data[id.z() * (width * height) + id.y() * width + id.x()]);
#endif
  }, output_it);
  OTensor.unmap();

  printf("output:\n");
  for(unsigned int b = 0; b < nchan; b++){
    for(unsigned int h = 0; h < height; h++){
     for(unsigned int w = 0; w < width; w++){
       printf("%f ", dst_data[b * (width * height) + h * width + w]);
     }
    }
  }
  printf("\n");

  // Compute time
  secs += (after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec)/1000000.0;
  std::cout << "Softmax[time]= " << secs; 
  double avg_time = secs;
    
  delete[] src_data;
  delete[] dst_data;
  return 0;
}
