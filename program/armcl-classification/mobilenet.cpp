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
#if EXCLUDE_MOBILENET != 0

#warning "Excluding MobileNet"

#else /* EXCLUDE_MOBILENET */

#include "benchmark-common.h"

#if defined(ARMCL_18_05_PLUS)
using namespace arm_compute::graph::frontend;
#endif

void run_mobilenet() {
  std::string data_path; /* Path to the trainable data */
  std::string image;     /* Image data */
  std::string label;     /* Label data */

#if defined(ARMCL_18_05_PLUS)
  std::unique_ptr<IPreprocessor> preprocessor = arm_compute::support::cpp14::make_unique<TFPreproccessor>();
#else
  constexpr float mean_r = 122.68f; /* Mean value to subtract from red channel */
  constexpr float mean_g = 116.67f; /* Mean value to subtract from green channel */
  constexpr float mean_b = 104.01f; /* Mean value to subtract from blue channel */
#endif

  unsigned int batch_size = get_batch_size(); /** Number of images per batch */

  auto target_hint        = get_target_hint();
  auto convolution_method = get_convolution_method();

#if defined(ARMCL_18_05_PLUS)
  auto depthwise_convolution_method = DepthwiseConvolutionMethod::OPTIMIZED_3x3;
#endif

  GRAPH(graph, "MobileNetV1");

  auto get_dwsc_node = [&](const std::string &data_path, std::string &&param_path, unsigned int  conv_filt,
                           PadStrideInfo dwc_pad_stride_info, PadStrideInfo conv_pad_stride_info) -> BranchLayer {
    std::string total_path = "/cnn_data/mobilenet_v1_model/" + param_path + "_";
#if defined(ARMCL_18_05_PLUS)
    SubStream sg(graph);
#else
    SubGraph sg;
#endif    
    sg << DepthwiseConvolutionLayer(
         3U, 3U,
         get_weights_accessor(data_path, total_path + "depthwise_depthwise_weights.npy"),
         std::unique_ptr<arm_compute::graph::ITensorAccessor>(nullptr),
         dwc_pad_stride_info)
       << BatchNormalizationLayer(
         get_weights_accessor(data_path, total_path + "depthwise_BatchNorm_moving_mean.npy"),
         get_weights_accessor(data_path, total_path + "depthwise_BatchNorm_moving_variance.npy"),
         get_weights_accessor(data_path, total_path + "depthwise_BatchNorm_beta.npy"),
         get_weights_accessor(data_path, total_path + "depthwise_BatchNorm_gamma.npy"),
         0.001f)
       << ActivationLayer(ActivationLayerInfo(ActivationLayerInfo::ActivationFunction::BOUNDED_RELU, 6.f))
       << ConvolutionLayer(
         1U, 1U, conv_filt,
         get_weights_accessor(data_path, total_path + "pointwise_weights.npy"),
         std::unique_ptr<arm_compute::graph::ITensorAccessor>(nullptr),
         conv_pad_stride_info)
       << BatchNormalizationLayer(
         get_weights_accessor(data_path, total_path + "pointwise_BatchNorm_moving_mean.npy"),
         get_weights_accessor(data_path, total_path + "pointwise_BatchNorm_moving_variance.npy"),
         get_weights_accessor(data_path, total_path + "pointwise_BatchNorm_beta.npy"),
         get_weights_accessor(data_path, total_path + "pointwise_BatchNorm_gamma.npy"),
         0.001f)
       << ActivationLayer(ActivationLayerInfo(ActivationLayerInfo::ActivationFunction::BOUNDED_RELU, 6.f));

    return BranchLayer(std::move(sg));
  };

  xopenme_clock_start(X_TIMER_SETUP);
  graph << target_hint
        << convolution_method
#if defined(ARMCL_18_05_PLUS)
        << depthwise_convolution_method
        << InputLayer(TensorDescriptor(TensorShape(224U, 224U, 3U, batch_size), DATATYPE),
                get_input_accessor(image, std::move(preprocessor), false))
#else
        << Tensor(TensorInfo(TensorShape(224U, 224U, 3U, batch_size), 1, DATATYPE),
                  get_input_accessor(image, mean_r, mean_g, mean_b))
#endif
        << ConvolutionLayer(
          3U, 3U, 32U,
          get_weights_accessor(data_path, "/cnn_data/mobilenet_v1_model/Conv2d_0_weights.npy"),
          std::unique_ptr<arm_compute::graph::ITensorAccessor>(nullptr),
          PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR))
        << BatchNormalizationLayer(
          get_weights_accessor(data_path, "/cnn_data/mobilenet_v1_model/Conv2d_0_BatchNorm_moving_mean.npy"),
          get_weights_accessor(data_path, "/cnn_data/mobilenet_v1_model/Conv2d_0_BatchNorm_moving_variance.npy"),
          get_weights_accessor(data_path, "/cnn_data/mobilenet_v1_model/Conv2d_0_BatchNorm_beta.npy"),
          get_weights_accessor(data_path, "/cnn_data/mobilenet_v1_model/Conv2d_0_BatchNorm_gamma.npy"),
          0.001f)

        << ActivationLayer(ActivationLayerInfo(ActivationLayerInfo::ActivationFunction::BOUNDED_RELU, 6.f))
        << get_dwsc_node(data_path, "Conv2d_1", 64, PadStrideInfo(1, 1, 1, 1), PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_2", 128, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_3", 128, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_4", 256, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_5", 256, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_6", 512, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_7", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_8", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_9", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_10", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_11", 512, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_12", 1024, PadStrideInfo(2, 2, 0, 1, 0, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << get_dwsc_node(data_path, "Conv2d_13", 1024, PadStrideInfo(1, 1, 1, 1, 1, 1, DimensionRoundingType::FLOOR),
                         PadStrideInfo(1, 1, 0, 0))
        << PoolingLayer(PoolingLayerInfo(PoolingType::AVG))
        << ConvolutionLayer(
          1U, 1U, 1001U,
          get_weights_accessor(data_path, "/cnn_data/mobilenet_v1_model/Logits_Conv2d_1c_1x1_weights.npy"),
          get_weights_accessor(data_path, "/cnn_data/mobilenet_v1_model/Logits_Conv2d_1c_1x1_biases.npy"),
          PadStrideInfo(1, 1, 0, 0))
        << ReshapeLayer(TensorShape(1001U))
        << SoftmaxLayer()
        << make_output_layer(label);

#if defined(ARMCL_18_05_PLUS)
        // Finalize graph
        GraphConfig config {};
        graph.finalize(target_hint, config);
#endif

  xopenme_clock_end(X_TIMER_SETUP);

  xopenme_clock_start(X_TIMER_TEST);
  graph.run();
  xopenme_clock_end(X_TIMER_TEST);
}

#endif /* EXCLUDE_MOBILENET */
