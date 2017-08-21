#ifdef XOPENME
#include <xopenme.h>
#endif

//#include <arm_compute/runtime/NEON/NEFunctions.h>

#define ARM_COMPUTE_CL /* So that OpenCL exceptions get caught too */
#include "arm_compute/core/Types.h"
#include "arm_compute/runtime/CL/CLFunctions.h"
#include "arm_compute/runtime/CL/CLScheduler.h"
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
         float r = static_cast <float> (rand()) / (static_cast <float> (RAND_MAX/MYMAX));
         src_data[b * (width * height) + h * width + w] = static_cast<float>(100 * b + 10 * h + w); //replace with random fixed seed value
       }
     }
   }
  auto kernel_file = std::vector<std::string>{"softmax_layer.cl"};
  cltune::Tuner tuner(size_t{0}, size_t{0});
  

// end data init 


// OpenCL init
  //CLScheduler::get().default_init();

  CLTensor ATensor; //NETensor for Neon 
  CLTensor OTensor;

  TensorShape shape(width, height, bsize);
  ATensor.allocator()->init(TensorInfo(shape,  Format::F32));
  OTensor.allocator()->init(TensorInfo(shape,  Format::F32));
  
  //FILL TENSORS... easiest way is: create an iteretor 
  Window input_window;
  input_window.use_tensor_dimensions(ATensor.info());
  if ((width*height*bsize) < 16){
   std::cout << " Dimensions of the input's iterator:\n";
   std::cout << " X = [start=" << input_window.x().start() << ", end=" << input_window.x().end() << ", step=" << input_window.x().step() << "]\n";
   std::cout << " Y = [start=" << input_window.y().start() << ", end=" << input_window.y().end() << ", step=" << input_window.y().step() << "]\n";
   std::cout << " Z = [start=" << input_window.z().start() << ", end=" << input_window.z().end() << ", step=" << input_window.z().step() << "]\n";
  }
  CLSoftmaxLayer softmax;
  softmax.configure(&ATensor,&OTensor);

  //Data in/out
  ATensor.allocator()->allocate();
  OTensor.allocator()->allocate();

  ATensor.map();
  Iterator input_it(&ATensor, input_window);
  execute_window_loop(input_window, [&](const Coordinates & id){
#ifdef PRINT
    std::cout << "Setting item [" << id.x() << "," << id.y() << "," << id.z() << "]\n";
#endif
    *reinterpret_cast<float *>(input_it.ptr()) = src_data[id.z() * (width * height) + id.y() * width + id.x()];
  },input_it);
  
  ATensor.unmap();
//Execution
  //softmax.run();
  //CLScheduler::get().sync();

//Get output
  Window output_window;
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



// Compute time
  secs += (after.tv_sec - before.tv_sec) + (after.tv_usec - before.tv_usec)/1000000.0;
  std::cout << "Softmax[time]= " << secs; 
  double avg_time = secs;
    
  delete[] src_data;
  delete[] dst_data;
  return 0;
}
