/*
 * Copyright (c) 2018 cTuning foundation.
 * See CK COPYRIGHT.txt for copyright details.
 *
 * SPDX-License-Identifier: BSD-3-Clause.
 * See CK LICENSE.txt for licensing details.
 */  

#include "image_helper.h"
#include "classification_demo.h"
#include "armcl_graph_common.h"

using namespace std;
using namespace CK::ClassificationDemo;

void setup_mobilenet(GraphObject& graph,
                     unsigned int image_size,
                     float multiplier,
                     const std::string& weights_dir,
                     const float *input_data_buffer,
                     float *output_data_buffer);

int main(int argc, char *argv[]) {
  try {
    init_armcl();
    init_demo();

    // Parse command line arguments
    string image_file;
    string weights_dir;
    string labels_file;
    string resolution_str;
    string multiplier_str;
    for (int i = 1; i < argc; i++) {
      get_arg(argv[i], "--image=", image_file) ||
      get_arg(argv[i], "--weights=", weights_dir) ||
      get_arg(argv[i], "--labels=", labels_file) ||
      get_arg(argv[i], "--resolution=", resolution_str) ||
      get_arg(argv[i], "--multiplier=", multiplier_str);
    }
    int resolution = atoi(resolution_str.c_str());
    float multiplier = atof(multiplier_str.c_str());
    check_file(image_file, "Image");
    check_file(labels_file, "Labels");
    cout << "Weighs dir: " << weights_dir << endl;
    cout << "Mobilenet resolution: " << resolution << endl;
    cout << "Mobilenet multiplier: " << multiplier << endl;

    vector<float> input(resolution * resolution * 3);
    vector<float> probes(1001);

    // Prepare graph
    GRAPH(graph, "MobileNetV1");
    measure_setup([&](){
      setup_mobilenet(graph, resolution, multiplier, weights_dir, input.data(), probes.data());
    });

    // Read input image
    measure_load_image([&](){
      ImageData img_data = load_jpeg_file(image_file);
      cout << "OK: Input image loaded: " << img_data.height << "x"
                                         << img_data.width << "x"
                                         << img_data.channels << endl;
      if (img_data.channels != 3)
        throw string("Only RGB images are supported");

      resize_image(input.data(), img_data, resolution, resolution);
    });

    // Classify image
    measure_classify([&](){
      graph.run();
    });
    cout << "OK: Image classified" << endl;

    // Process results
    print_predictions(image_file,
                      get_top_n(probes, 5, true),
                      load_labels(labels_file));

    finish_demo();
  }
  catch (const string& error_message) {
    cout << "ERROR: " << error_message << endl;
    return -1;
  }
  return 0;
}
