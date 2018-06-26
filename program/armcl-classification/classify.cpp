/*
 * Copyright (c) 2017 ARM Limited.
 *
 * SPDX-License-Identifier: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "benchmark-common.h"

#if defined(ARMCL_18_05_PLUS)
#include <arm_compute/graph/backends/BackendRegistry.h>
#include <arm_compute/graph/backends/CL/CLDeviceBackend.h>
#endif

// Forward declarations
void run_alexnet();
void run_googlenet();
void run_lenet();
void run_mobilenet();
void run_squeezenet();
void run_squeezenet11();
void run_vgg16();
void run_vgg19();


const char *GLOBAL_VAR[GLOBAL_TIMER_COUNT] = {
  [X_TIMER_SETUP] = "setup",
  [X_TIMER_TEST] = "test"
};

static int VAR_COUNT;
static const char **VAR;

void printf_callback(const char *buffer, unsigned int len, size_t complete, void *user_data) {
  printf("%.*s", len, buffer);
}

void set_kernel_path() {
  const char *kernel_path = getenv("CK_ENV_LIB_ARMCL_CL_KERNELS");
  if (kernel_path) {
    printf("Kernel path: %s\n", kernel_path);
    arm_compute::CLKernelLibrary::get().set_kernel_path(kernel_path);
  }
}

void init_armcl(arm_compute::ICLTuner *cl_tuner = nullptr) {
  cl_context_properties properties[] = {
    CL_PRINTF_CALLBACK_ARM, reinterpret_cast<cl_context_properties>(printf_callback),
    CL_PRINTF_BUFFERSIZE_ARM, static_cast<cl_context_properties>(0x100000),
    CL_CONTEXT_PLATFORM, reinterpret_cast<cl_context_properties>(cl::Platform::get()()),
    0
  };
  cl::Context::setDefault(cl::Context(CL_DEVICE_TYPE_DEFAULT, properties));
  arm_compute::CLScheduler::get().default_init(cl_tuner);

  // Should be called after initialization
  set_kernel_path();

#if defined(ARMCL_18_05_PLUS)
  arm_compute::graph::backends::BackendRegistry::get().add_backend<arm_compute::graph::backends::CLDeviceBackend>(arm_compute::graph::Target::CL);
#endif
}

void finish_test() {
  for (int i = 0; i < VAR_COUNT; ++i) {
    float v = xopenme_get_timer(i);
    printf("%s time: %f\n", VAR[i], v);
    store_value_f(i, VAR[i], v);
  }
  xopenme_dump_state();
  xopenme_finish();
}

int main(int argc, const char **argv) {
  std::string network = getenv("CK_NETWORK") ? getenv("CK_NETWORK") : "alexnet";
  std::transform(network.begin(), network.end(), network.begin(), ::tolower);

  auto func = run_alexnet;
  if ("googlenet" == network) {
    std::cout << "Using GoogLeNet" << std::endl;
    func = run_googlenet;
  }
  else if ("squeezenet" == network) {
    std::cout << "Using SqueezeNet 1.0" << std::endl;
    func = run_squeezenet;
  }
  else if ("squeezenet11" == network) {
    std::cout << "Using SqueezeNet 1.1" << std::endl;
    func = run_squeezenet11;
  }
  else if ("lenet" == network) {
    std::cout << "Using LeNet" << std::endl;
    func = run_lenet;
  }
  else if ("mobilenet" == network) {
#if EXCLUDE_MOBILENET == 0
    std::cout << "Using MobileNet" << std::endl;
    func = run_mobilenet;
#else
    std::cout << "Excluding MobileNet" << std::endl;
    func = nullptr;
#endif
  }
  else if ("vgg16" == network) {
    std::cout << "Using VGG16" << std::endl;
    func = run_vgg16;
  }
  else if ("vgg19" == network) {
    std::cout << "Using VGG19" << std::endl;
    func = run_vgg19;
  }
  else {
    std::cout << "Using AlexNet" << std::endl;
    func = run_alexnet;
  }
  VAR = GLOBAL_VAR;
  VAR_COUNT = GLOBAL_TIMER_COUNT;

  xopenme_init(VAR_COUNT, VAR_COUNT);
  init_armcl();

  std::cout << "\n" << argv[0] << "\n\n";

  int status = EXIT_SUCCESS;
  try {
    func();

    std::cout << "\nTest PASSED\n";
  }
  catch(cl::Error &err) {
    std::cerr << "!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
    std::cerr << std::endl
              << "ERROR " << err.what() << "(" << err.err() << ")" << std::endl;
    std::cerr << "!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
    status = EXIT_FAILURE;
  }
  catch(std::runtime_error &err) {
    std::cerr << "!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
    std::cerr << std::endl
              << "ERROR " << err.what() << " " << (errno ? strerror(errno) : "") << std::endl;
    std::cerr << "!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;
    status = EXIT_FAILURE;
  }

  if(EXIT_SUCCESS != status) {
    std::cout << "\nTest FAILED\n";
  }

  finish_test();
  fflush(stdout);
  fflush(stderr);

  return status;
}
