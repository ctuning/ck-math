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

#ifndef BENCHMARK_COMMON_H
#define BENCHMARK_COMMON_H

#if defined(ARMCL_18_05_PLUS)
#include <arm_compute/graph.h>
#include <arm_compute/graph/nodes/Nodes.h>
#else
#include <arm_compute/graph/Graph.h>
#include <arm_compute/graph/Nodes.h>
#endif

#include <arm_compute/runtime/CL/CLScheduler.h>
#include <arm_compute/runtime/CPP/CPPScheduler.h>
#include <arm_compute/runtime/Scheduler.h>
#include <support/ToolchainSupport.h>
#include <arm_compute/runtime/CL/CLTuner.h>
#include <arm_compute/core/Helpers.h>
#include <arm_compute/core/ITensor.h>

#include "GraphUtils.h"
#include "Utils.h"

#include <xopenme.h>

#include <cstdlib>
#include <iostream>
#include <memory>

#include <algorithm>
#include <string>

enum GLOBAL_TIMER {
  X_TIMER_SETUP,
  X_TIMER_TEST,

  GLOBAL_TIMER_COUNT
};

extern const char *GLOBAL_VAR[GLOBAL_TIMER_COUNT];

using namespace arm_compute::graph;
using namespace arm_compute::graph_utils;

inline int getenv_i(const char *name, int def) {
  return getenv(name) ? atoi(getenv(name)) : def;
}

inline float getenv_f(const char *name, float def) {
  return getenv(name) ? atof(getenv(name)) : def;
}

inline void store_value_f(int index, const char *name, float value) {
  char *json_name = new char[strlen(name) + 6];
  sprintf(json_name, "\"%s\":%%f", name);
  xopenme_add_var_f(index, json_name, value);
  delete[] json_name;
}

inline std::unique_ptr<ITensorAccessor> get_default_input_accessor() {
  auto seed = static_cast<std::random_device::result_type>(getenv_i("CK_SEED", 42));
  float lower = getenv_f("CK_LOWER_BOUND", 0);
  float upper = getenv_f("CK_UPPER_BOUND", 1);
  return arm_compute::support::cpp14::make_unique<RandomAccessor>(lower, upper, seed);
}

inline unsigned int get_batch_size() {
  return static_cast<unsigned int>(getenv_i("CK_BATCH_SIZE", 1));
}

#ifndef DATATYPE
#define DATATYPE DataType::F32
#endif

#if defined(ARMCL_18_05_PLUS)
inline ConvolutionMethod get_convolution_method() {
  auto method_name = getenv("CK_CONVOLUTION_METHOD");
  if (!method_name) {
      bool bifrost_target = (arm_compute::CLScheduler::get().target() == arm_compute::GPUTarget::BIFROST);
      return (bifrost_target ? ConvolutionMethod::DIRECT : ConvolutionMethod::GEMM);
  }
  // Try to get convolution method by its name
  if (strcmp(method_name, "DEFAULT") == 0) return ConvolutionMethod::DEFAULT;
  if (strcmp(method_name, "GEMM") == 0) return ConvolutionMethod::GEMM;
  if (strcmp(method_name, "DIRECT") == 0) return ConvolutionMethod::DIRECT;
  if (strcmp(method_name, "WINOGRAD") == 0) return ConvolutionMethod::WINOGRAD;
  // Try to get convolution method as integer value.
  // ConvolutionMethod enum has additional item comparing to ConvolutionMethodHint.
  // So we shift int value here to be consistent with old version: 0 = GEMM, 1 = DIRECT
  return static_cast<ConvolutionMethod>(atoi(method_name)+1);
}

inline arm_compute::graph::Target get_target_hint() {
  return arm_compute::graph::Target::CL;
}

#define GRAPH(graph_var, graph_name)\
  arm_compute::graph::frontend::Stream graph_var{ 0, graph_name };

inline arm_compute::graph::frontend::InputLayer make_input_layer(const std::string& image,
                                                                 unsigned int W,
                                                                 unsigned int H,
                                                                 unsigned int C,
                                                                 const std::array<float, 3>& mean_rgb) {
  std::unique_ptr<arm_compute::graph_utils::IPreprocessor> preprocessor =
    arm_compute::support::cpp14::make_unique<arm_compute::graph_utils::CaffePreproccessor>(mean_rgb);
  
  arm_compute::TensorShape input_shape(W, H, C, get_batch_size());
  arm_compute::graph::TensorDescriptor inputDescriptor(input_shape, DATATYPE);
  return arm_compute::graph::frontend::InputLayer(inputDescriptor,
    arm_compute::graph_utils::get_input_accessor(image, std::move(preprocessor)));
}

inline arm_compute::graph::frontend::OutputLayer make_output_layer(const std::string& label) {
  return arm_compute::graph::frontend::OutputLayer(
    arm_compute::graph_utils::get_output_accessor(label, 5));
}

#else // ArmCL < 18.05

inline ConvolutionMethodHint get_convolution_method() {
  auto method_name = getenv("CK_CONVOLUTION_METHOD");
  if (!method_name) {
      bool bifrost_target = (arm_compute::CLScheduler::get().target() == arm_compute::GPUTarget::BIFROST);
      return (bifrost_target ? ConvolutionMethodHint::DIRECT : ConvolutionMethodHint::GEMM);
  }
  // Try to get convolution method by its name
  if (strcmp(method_name, "GEMM") == 0) return ConvolutionMethodHint::GEMM;
  if (strcmp(method_name, "DIRECT") == 0) return ConvolutionMethodHint::DIRECT;
  // Try to get convolution method as integer value.
  return static_cast<ConvolutionMethodHint>(atoi(method_name));
}

inline TargetHint get_target_hint() {
  return TargetHint::OPENCL;
}

#define GRAPH(graph_var, graph_name)\
  arm_compute::graph::Graph graph_var;

inline arm_compute::graph::Tensor make_input_layer(const std::string& image,
                                                   unsigned int W,
                                                   unsigned int H,
                                                   unsigned int C,
                                                   const std::array<float, 3>& mean_rgb) {
  arm_compute::TensorShape input_shape(W, H, C, get_batch_size());
  return arm_compute::graph::Tensor(arm_compute::TensorInfo(input_shape, 1, DATATYPE),
    arm_compute::graph_utils::get_input_accessor(image, mean_rgb[0], mean_rgb[1], mean_rgb[2]));
}

inline arm_compute::graph::Tensor make_output_layer(const std::string& label) {
  return arm_compute::graph::Tensor(
    arm_compute::graph_utils::get_output_accessor(label, 5));
}

#endif // ArmCL version dependent

#endif // BENCHMARK_COMMON_H
