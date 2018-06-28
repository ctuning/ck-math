/*
 * Copyright (c) 2017-2018 ARM Limited.
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

#include "armcl_graph_common.h"

#include <GraphUtils.h>
#include <utils/Utils.h>

using namespace arm_compute;
using namespace arm_compute::graph;
using namespace arm_compute::graph_utils;
#if defined(ARMCL_18_05_PLUS)
using namespace arm_compute::graph::frontend;
#endif


class CKInputAccessor : public ITensorAccessor {
public:
  CKInputAccessor(const float *buffer): _buffer(buffer) {}
  CKInputAccessor(CKInputAccessor &&) = default;

  bool access_tensor(ITensor &tensor) override {
    const size_t num_pixels = tensor.info()->dimension(0) *
                              tensor.info()->dimension(1) *
                              tensor.info()->dimension(2) *
                              tensor.info()->dimension(3);
    float* target = reinterpret_cast<float*>(tensor.buffer() + tensor.info()->offset_first_element_in_bytes());
    std::copy(_buffer, _buffer + num_pixels, target);
    return true;
  }

private:
  const float *_buffer;
};


class CKOutputAccessor : public ITensorAccessor {
public:
  CKOutputAccessor(float* buffer): _buffer(buffer) {}
  CKOutputAccessor(CKOutputAccessor &&) = default;

  bool access_tensor(ITensor &tensor) override {
    const size_t num_classes = tensor.info()->dimension(0);
    float* probes = reinterpret_cast<float*>(tensor.buffer() + tensor.info()->offset_first_element_in_bytes());
    std::copy(probes, probes + num_classes, _buffer);
    return true;
  }

private:
  float* _buffer;
};

inline std::unique_ptr<ITensorAccessor> empty_accessor() {
    return std::unique_ptr<ITensorAccessor>(nullptr);
}

void setup_mobilenet(GraphObject& graph,
                     unsigned int image_size,
                     float multiplier,
                     const std::string& weights_dir,
                     const float *input_data_buffer,
                     float *output_data_buffer)
{
    TensorShape input_shape(image_size, image_size, 3U, 1U);

    auto weights_accessor = [&](const std::string &file) -> std::unique_ptr<ITensorAccessor> {
        return arm_compute::support::cpp14::make_unique<NumPyBinLoader>(weights_dir + '/' + file);
    };

    auto get_dwsc_node = [&](std::string &&param_path,
                             unsigned int  conv_filt,
                             PadStrideInfo dwc_pad_stride_info,
                             PadStrideInfo conv_pad_stride_info) {
#if defined(ARMCL_18_05_PLUS)
      SubStream sg(graph);
#else
      SubGraph sg;
#endif   
      sg << DepthwiseConvolutionLayer(
             3U, 3U,
             weights_accessor(param_path + "_depthwise_depthwise_weights.npy"),
             empty_accessor(),
             dwc_pad_stride_info)
         << BatchNormalizationLayer(
             weights_accessor(param_path + "_depthwise_BatchNorm_moving_mean.npy"),
             weights_accessor(param_path + "_depthwise_BatchNorm_moving_variance.npy"),
             weights_accessor(param_path + "_depthwise_BatchNorm_gamma.npy"),
             weights_accessor(param_path + "_depthwise_BatchNorm_beta.npy"),
             0.001f)
         << ActivationLayer(ActivationLayerInfo(ActivationLayerInfo::ActivationFunction::BOUNDED_RELU, 6.f))
         << ConvolutionLayer(
             1U, 1U, static_cast<unsigned int>(conv_filt * multiplier),
             weights_accessor(param_path + "_pointwise_weights.npy"),
             empty_accessor(),
             conv_pad_stride_info)
         << BatchNormalizationLayer(
             weights_accessor(param_path + "_pointwise_BatchNorm_moving_mean.npy"),
             weights_accessor(param_path + "_pointwise_BatchNorm_moving_variance.npy"),
             weights_accessor(param_path + "_pointwise_BatchNorm_gamma.npy"),
             weights_accessor(param_path + "_pointwise_BatchNorm_beta.npy"),
             0.001f)
         << ActivationLayer(ActivationLayerInfo(ActivationLayerInfo::ActivationFunction::BOUNDED_RELU, 6.f));
      return BranchLayer(std::move(sg));
    };

    auto target_hint = get_target_hint();

    graph << target_hint
          << get_convolution_method()
#if defined(ARMCL_18_05_PLUS)
          << DepthwiseConvolutionMethod::OPTIMIZED_3x3
          << InputLayer(TensorDescriptor(input_shape, DATATYPE),
                arm_compute::support::cpp14::make_unique<CKInputAccessor>(input_data_buffer))
#else
          << arm_compute::graph::Tensor(TensorInfo(input_shape, 1, DATATYPE),
                arm_compute::support::cpp14::make_unique<CKInputAccessor>(input_data_buffer))
#endif
          << ConvolutionLayer(
              3U, 3U, static_cast<unsigned int>(32 * multiplier),
              weights_accessor("Conv2d_0_weights.npy"),
              empty_accessor(),
              PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR))
          << BatchNormalizationLayer(
              weights_accessor("Conv2d_0_BatchNorm_moving_mean.npy"),
              weights_accessor("Conv2d_0_BatchNorm_moving_variance.npy"),
              weights_accessor("Conv2d_0_BatchNorm_gamma.npy"),
              weights_accessor("Conv2d_0_BatchNorm_beta.npy"),
              0.001f)

          << ActivationLayer(ActivationLayerInfo(ActivationLayerInfo::ActivationFunction::BOUNDED_RELU, 6.f))
          << get_dwsc_node("Conv2d_1", 64, PadStrideInfo(1, 1, 1, 1), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_2", 128, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_3", 128, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_4", 256, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_5", 256, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_6", 512, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_7", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_8", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_9", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_10", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_11", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_12", 1024, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << get_dwsc_node("Conv2d_13", 1024, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR), PadStrideInfo(1, 1, 0, 0))
          << PoolingLayer(PoolingLayerInfo(PoolingType::AVG))
          << ConvolutionLayer(
              1U, 1U, 1001U,
              weights_accessor("Logits_Conv2d_1c_1x1_weights.npy"),
              weights_accessor("Logits_Conv2d_1c_1x1_biases.npy"),
              PadStrideInfo(1, 1, 0, 0))
          << ReshapeLayer(TensorShape(1001U))
          << SoftmaxLayer()
#if defined(ARMCL_18_05_PLUS)
          << OutputLayer(arm_compute::support::cpp14::make_unique<CKOutputAccessor>(output_data_buffer));
#else
          << arm_compute::graph::Tensor(arm_compute::support::cpp14::make_unique<CKOutputAccessor>(output_data_buffer));
#endif

#if defined(ARMCL_18_05_PLUS)
    // Finalize graph
    GraphConfig config {};
    graph.finalize(target_hint, config);
#endif
}
