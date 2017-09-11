#ifdef XOPENME
#include <xopenme.h>
#endif

#include <arm_compute/runtime/NEON/NEFunctions.h>

#define ARM_COMPUTE_CL /* So that OpenCL exceptions get caught too */
#include "arm_compute/core/Types.h"
#include "arm_compute/runtime/CL/CLFunctions.h"
#include "arm_compute/runtime/CL/CLScheduler.h"
#include "tests/Utils.h"


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


#include "cltune.h"


using namespace arm_compute;
//using namespace test_helpers;
# define MYTIMER2 struct timeval
static MYTIMER2 before, after;
static double secs;
#define MYMAX 100




int main( int argc, char *argv[] )
{

  int r=0;
/*data init to be replaced with ppm images*/
  unsigned int width  = 16;
  unsigned int height = 16;
  unsigned int bsize = 2;
  unsigned int seed = 12;
  
  if (getenv("CK_WIDTH")!=NULL)  width=atol(getenv("CK_WIDTH"));
  if (getenv("CK_HEIGHT")!=NULL)  height=atol(getenv("CK_HEIGHT"));
  if (getenv("CK_BSIZE")!=NULL)  bsize=atol(getenv("CK_BSIZE"));
  std::cout << "WIDTH, HEIGHT, BSIZE " << width << " " <<  height << " " << bsize << "\n";
  if (getenv("CK_SEED")!=NULL)  seed=atol(getenv("CK_SEED"));
  std::cout << "CK_SEED " << seed << "\n";
  srand(seed);
  

  auto *src_data = new float[width * height * bsize];  
  auto *dst_data = new float[width * height * bsize];
  for(unsigned int b = 0; b < bsize; b++){
     for(unsigned int h = 0; h < height; h++){
       for(unsigned int w = 0; w < width; w++){
   //      float r = static_cast <float> (rand()) / (static_cast <float> (RAND_MAX/MYMAX));
         src_data[b * (width * height) + h * width + w] = static_cast<float>(100 * b + 10 * h + w); //replace with random fixed seed value
         dst_data[b * (width * height) + h * width + w] = 0;
       }
     }
   }
  //tuner.AddArgumentInput(src_data);
  //tuner.AddArgumentInput(dst_data);
  //tuner.AddArgumentScalar(static_cast<int>(width));
  //tuner.SetNumRuns(2);
  //tuner.Tune();
  //tuner.PrintToScreen();
// OpenCL init
  CLScheduler::get().default_init();

  CLTensor ATensor; //NETensor for Neon 
  CLTensor OTensor;

  TensorShape shape(width, height, bsize);
  ATensor.allocator()->init(TensorInfo(shape,  Format::F32));
  OTensor.allocator()->init(TensorInfo(shape,  Format::F32));
  
  //FILL TENSORS... easiest way is: create an iteretor 
  Window input_window,output_window;
  input_window.use_tensor_dimensions(ATensor.info());
  output_window.use_tensor_dimensions(ATensor.info());
  //Data in/out
  ATensor.allocator()->allocate();
  OTensor.allocator()->allocate();

  ATensor.map();
  Iterator input_it(&ATensor, input_window);
  execute_window_loop(input_window, [&](const Coordinates & id){
    *reinterpret_cast<float *>(input_it.ptr()) = src_data[id.z() * (width * height) + id.y() * width + id.x()];
  },input_it);
  
  ATensor.unmap();

  const ITensorInfo *Ainfo    = ATensor.info();
  const ITensorInfo *Oinfo    = OTensor.info();
  const unsigned int num_elems_processed_per_iteration = ceil_to_multiple(ATensor.info()->dimension(0),16);
  printf("[KERNEL SET-UP] num_elems_processed_per_iteration=%d\n",num_elems_processed_per_iteration);   if (ATensor.info()->dimension(0) % 16 != 0){
     setenv("CLTUNE_BUILD_OPTION","-DNON_MULTIPLE_OF_16", true);
     printf("SET CLTUNE BUILD\n");

  }
  printf("READ %s\n",getenv("CLTUNE_BUILD_OPTION"));
  auto kernel_file = std::vector<std::string>{"/home/flavio/CK_REPOS/ck-math/program/acl-softmax-opencl-tuner/softmax_layer2.cl"};

  cltune::Tuner tuner(size_t{0}, size_t{0});
  unsigned int gws_x = (input_window.x().end()-input_window.x().start())/16;
  unsigned gws_y =(input_window.y().end()-input_window.y().start())/1;

  const auto id = tuner.AddKernel(kernel_file, "softmax_layer_max", {1, gws_y}, {1,1});  
  tuner.AddParameter(id, "GROUP_SIZE", {1, 2, 4, 8, 16, 32});
  tuner.MulLocalSize(id, {"GROUP_SIZE"});

  const Strides     &Astrides = Ainfo->strides_in_bytes();
  unsigned int Aoffset_first_element = Ainfo->offset_first_element_in_bytes();

  for(unsigned int n = 0; n < Ainfo->num_dimensions(); ++n){
	Aoffset_first_element += input_window[n].start() * Astrides[n];
  }

  const Strides     &Ostrides = Oinfo->strides_in_bytes();
  unsigned int Ooffset_first_element = Oinfo->offset_first_element_in_bytes();

  for(unsigned int n = 0; n < Oinfo->num_dimensions(); ++n){
	Ooffset_first_element += output_window[n].start() * Ostrides[n];
  }

  std::vector<float> v(src_data, src_data + sizeof src_data / sizeof src_data[0]);
  std::vector<float> vout(dst_data, dst_data + sizeof dst_data / sizeof dst_data[0]);

  uint step_y = 1;
/*
  tuner.AddArgumentInput(v);
  tuner.AddArgumentScalar(static_cast<unsigned int>(Astrides[0])); 
  tuner.AddArgumentScalar(static_cast<unsigned int>(width)); 
  tuner.AddArgumentScalar(static_cast<unsigned int>(Astrides[1])); 
  tuner.AddArgumentScalar(static_cast<unsigned int>(step_y)); 
  tuner.AddArgumentScalar(static_cast<unsigned int>(Aoffset_first_element));
  tuner.AddArgumentScalar(static_cast<unsigned int>(Ostrides[0])); 
  tuner.AddArgumentInput(vout);
  tuner.AddArgumentScalar(static_cast<unsigned int>(Ostrides[1])); 
  tuner.AddArgumentScalar(static_cast<unsigned int>(step_y)); 
  tuner.AddArgumentScalar(static_cast<unsigned int>(Ooffset_first_element));
  tuner.AddArgumentScalar(static_cast<unsigned  int>(width));

  tuner.SetNumRuns(10);
  tuner.Tune();
*/
  tuner.PrintToScreen();
//Get output
/*  Window output_window;
  output_window.use_tensor_dimensions(OTensor.info());

  OTensor.map();
  Iterator output_it(&OTensor, output_window);
  execute_window_loop(output_window, [&](const Coordinates & id){
#ifdef PRINT
    std::cout << "Copying one row starting from [" << id.x() << "," << id.y() << "," << id.z() << "]\n";
#endif
    // Copy one whole row:
    memcpy(dst_data + id.z() * (width * height) + id.y() * width, output_it.ptr(), width * sizeof(float));
  }, output_it);
  OTensor.unmap();
*/


// Compute time
//  secs += (after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec)/1000000.0;
//  std::cout << "Softmax[time]= " << secs; 
//  double avg_time = secs;
    
  delete[] src_data;
  delete[] dst_data;
  return 0;
}
