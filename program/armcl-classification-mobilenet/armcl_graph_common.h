/*
 * Copyright (c) 2018 cTuning foundation.
 * See CK COPYRIGHT.txt for copyright details.
 *
 * SPDX-License-Identifier: BSD-3-Clause.
 * See CK LICENSE.txt for licensing details.
 */

#pragma once

#if defined(ARMCL_18_05_PLUS)
#include <arm_compute/graph.h>
#include <arm_compute/graph/nodes/Nodes.h>
#include <arm_compute/graph/backends/BackendRegistry.h>
#include <arm_compute/graph/backends/CL/CLDeviceBackend.h>
#include <arm_compute/runtime/CL/tuners/BifrostTuner.h>
#else
#include <arm_compute/graph/Graph.h>
#include <arm_compute/graph/Nodes.h>
#include <arm_compute/runtime/CL/CLScheduler.h>
#endif

#ifndef DATATYPE
#define DATATYPE DataType::F32
#endif

inline void printf_callback(const char *buffer, unsigned int len, size_t complete, void *user_data) {
  printf("%.*s", len, buffer);
}

inline void set_kernel_path() {
  const char* kernel_path = getenv("CK_ENV_LIB_ARMCL_CL_KERNELS");
  if (kernel_path) {
    printf("Kernel path: %s\n", kernel_path);
    arm_compute::CLKernelLibrary::get().set_kernel_path(kernel_path);
  }
}

inline void init_armcl(arm_compute::ICLTuner *cl_tuner = nullptr) {
  cl_context_properties properties[] =
  {
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
  arm_compute::graph::backends::BackendRegistry::get()
    .add_backend<arm_compute::graph::backends::CLDeviceBackend>(
      arm_compute::graph::Target::CL);
#endif
}

enum TunerType {
  CL_TUNER_NONE,
  CL_TUNER_DEFAULT,
  CL_TUNER_BIFROST,
};

inline TunerType get_lws_tuner_type() {
  auto tuner_type = getenv("CK_LWS_TUNER_TYPE");

  if (!tuner_type || strcmp(tuner_type, "NONE") == 0)
    return CL_TUNER_NONE;

  if (strcmp(tuner_type, "DEFAULT") == 0)
    return CL_TUNER_DEFAULT;

  if (strcmp(tuner_type, "BIFROST") == 0)
    return CL_TUNER_BIFROST;

  printf("WARNING: Unknown tuner type: %s\n", tuner_type);
  return CL_TUNER_NONE;
}

using TunerPtr = std::unique_ptr<arm_compute::ICLTuner>;

inline TunerPtr get_lws_tuner(TunerType tuner_type) {
  switch (tuner_type) {
    case CL_TUNER_NONE:
      return TunerPtr();

    case CL_TUNER_DEFAULT:
      printf("INFO: Tuner selected: CLTuner\n");
      return TunerPtr(new arm_compute::CLTuner());

    case CL_TUNER_BIFROST:
#if defined(ARMCL_18_05_PLUS)
      printf("INFO: Tuner selected: BifrostTuner\n");
      auto device = cl::Device::getDefault();
      auto gpu_target = arm_compute::get_target_from_device(device);
      auto gpu_arch = arm_compute::get_arch_from_target(gpu_target);
      if (gpu_arch != arm_compute::GPUTarget::BIFROST) {
        printf("WARNING: BifrostTuner selected for non-Bifrost architecture.\n");
      }
      return TunerPtr(new arm_compute::tuners::BifrostTuner());
#else
      printf("WARNING: BifrostTuner is only available for ArmCL v18.05 and later. "
             "Default CLTuner will be used instead.\n");
      printf("INFO: Tuner selected: CLTuner\n");
      return TunerPtr(new arm_compute::CLTuner());
#endif
  }
  return TunerPtr();
}


#if defined(ARMCL_18_05_PLUS)

#define ConvolutionMethod_GEMM arm_compute::graph::ConvolutionMethod::GEMM
#if defined(ARMCL_18_08_PLUS)
  #define ConvolutionMethod_DEFAULT arm_compute::graph::ConvolutionMethod::Default
  #define ConvolutionMethod_DIRECT arm_compute::graph::ConvolutionMethod::Direct
  #define ConvolutionMethod_WINOGRAD arm_compute::graph::ConvolutionMethod::Winograd

  #define DepthwiseConvolutionMethod_OPTIMIZED_3x3 arm_compute::graph::DepthwiseConvolutionMethod::Optimized3x3
#else
  #define ConvolutionMethod_DEFAULT arm_compute::graph::ConvolutionMethod::DEFAULT
  #define ConvolutionMethod_DIRECT arm_compute::graph::ConvolutionMethod::DIRECT
  #define ConvolutionMethod_WINOGRAD arm_compute::graph::ConvolutionMethod::WINOGRAD

  #define DepthwiseConvolutionMethod_OPTIMIZED_3x3 arm_compute::graph::DepthwiseConvolutionMethod::OPTIMIZED_3x3
#endif

inline arm_compute::graph::ConvolutionMethod str_to_convolution_method(const char *method_name) {
  if (!method_name || strlen(method_name) == 0)
    return ConvolutionMethod_DEFAULT;

  // Try to get convolution method by its name
  if (strcmp(method_name, "DEFAULT") == 0) return ConvolutionMethod_DEFAULT;
  if (strcmp(method_name, "GEMM") == 0) return ConvolutionMethod_GEMM;
  if (strcmp(method_name, "DIRECT") == 0) return ConvolutionMethod_DIRECT;
  if (strcmp(method_name, "WINOGRAD") == 0) return ConvolutionMethod_WINOGRAD;

  // Try to get convolution method as integer value.
  switch (atoi(method_name)) {
    case 0: return ConvolutionMethod_GEMM;
    case 1: return ConvolutionMethod_DIRECT;
    case 2: return ConvolutionMethod_WINOGRAD;
  }

  return ConvolutionMethod_DEFAULT;
}

inline arm_compute::graph::Target get_target_hint() {
  return arm_compute::graph::Target::CL;
}

#define GRAPH(graph_var, graph_name)\
  arm_compute::graph::frontend::Stream graph_var{ 0, graph_name };

using GraphObject = arm_compute::graph::frontend::Stream;

#else // ArmCL < 18.05

inline arm_compute::graph::ConvolutionMethodHint str_to_convolution_method(const char *method_name) {
  if (!method_name || strlen(method_name) == 0)
    return arm_compute::graph::ConvolutionMethodHint::GEMM;

  // Try to get convolution method by its name
  if (strcmp(method_name, "GEMM") == 0) return arm_compute::graph::ConvolutionMethodHint::GEMM;
  if (strcmp(method_name, "DIRECT") == 0) return arm_compute::graph::ConvolutionMethodHint::DIRECT;
  
  // Try to get convolution method as integer value.
  switch (atoi(method_name)) {
    case 0: return arm_compute::graph::ConvolutionMethodHint::GEMM;
    case 1: return arm_compute::graph::ConvolutionMethodHint::DIRECT;
  }
  
  return arm_compute::graph::ConvolutionMethodHint::GEMM;
}

inline arm_compute::graph::TargetHint get_target_hint() {
  return arm_compute::graph::TargetHint::OPENCL;
}

#define GRAPH(graph_var, graph_name) \
  arm_compute::graph::Graph graph_var;

using GraphObject = arm_compute::graph::Graph;

#endif // ArmCL < 18.05

inline auto get_convolution_method() -> decltype(str_to_convolution_method("")) {
  auto method_name = getenv("CK_CONVOLUTION_METHOD");
  if (method_name)
    return str_to_convolution_method(method_name);

  if (arm_compute::CLScheduler::get().target() == arm_compute::GPUTarget::BIFROST)
#if defined(ARMCL_18_08_PLUS)
    return decltype(str_to_convolution_method(""))::Direct;
#else
    return decltype(str_to_convolution_method(""))::DIRECT;
#endif
        
  return decltype(str_to_convolution_method(""))::GEMM;
}

enum CKDataLayout {
  LAYOUT_NCHW,
  LAYOUT_NHWC,
};
