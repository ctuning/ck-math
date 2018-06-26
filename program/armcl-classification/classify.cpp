/*
 * Copyright (c) 2018 cTuning foundation.
 * See CK COPYRIGHT.txt for copyright details.
 *
 * SPDX-License-Identifier: BSD-3-Clause.
 * See CK LICENSE.txt for licensing details.
 */  

#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

#include <stdlib.h>

#ifdef XOPENME
#include <xopenme.h>
#endif

#include "image_helper.h"

enum X_TIMERS {
  X_TIMER_SETUP,
  X_TIMER_LOAD_IMAGE,
  X_TIMER_CLASSIFY,

  X_TIMER_COUNT
}; 

using namespace std;

bool get_arg(const char* arg, const char* key, string& target) {
  if (strncmp(arg, key, strlen(key)) == 0) {
    target = &arg[strlen(key)];
    return true;
  }
  return false;
}

void check_file(const string& path, const string& id) {
  if (path.empty())
    throw id + " file path is not specified";
  if (!ifstream(path).good())
    throw id + " file can't be opened, check if it exists";
  cout << id << " file: " << path << endl;
}

int main(int argc, char *argv[]) {
  try {
#ifdef XOPENME
    xopenme_init(X_TIMER_COUNT, 0);
#endif

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
    int multiplier = atoi(multiplier_str.c_str());
    check_file(image_file, "Image");
    check_file(labels_file, "Labels");
    cout << "Weighs dir: " << weights_dir << endl;
    cout << "Mobilenet resolution: " << resolution << endl;
    cout << "Mobilenet multiplier: " << multiplier << endl;

    // Load network from ftlite file
#ifdef XOPENME
    xopenme_clock_start(X_TIMER_SETUP);
#endif
    // TODO
    cout << "SETUP HERE" << endl;
#ifdef XOPENME
    xopenme_clock_end(X_TIMER_SETUP);
#endif

    // Read input image
#ifdef XOPENME
    xopenme_clock_start(X_TIMER_LOAD_IMAGE);
#endif
    ImageData img_data = load_jpeg_file(image_file);
    cout << "OK: Input image loaded: " << img_data.height << "x"
                                       << img_data.width << "x"
                                       << img_data.channels << endl;
    if (img_data.channels != 3)
      throw string("Only RGB images are supported");

    // Prepare input image
    int wanted_height = 224;
    int wanted_width = 224;
    int wanted_channels = 3;
    if (wanted_channels != img_data.channels)
      throw string("Unsupported channels number in model");
    vector<float> resized_img_data(wanted_height * wanted_width * wanted_channels);
    resize_image(resized_img_data.data(), img_data, wanted_height, wanted_width);
#ifdef XOPENME
    xopenme_clock_end(X_TIMER_LOAD_IMAGE);
#endif

    // Classify image
    long ct_repeat_max = getenv("CT_REPEAT_MAIN") ? atol(getenv("CT_REPEAT_MAIN")) : 1;
#ifdef XOPENME
    xopenme_clock_start(X_TIMER_CLASSIFY);
#endif
    for (int i = 0; i < ct_repeat_max; i++) {
      // TODO
      cout << "CLASSIFICATION HERE" << endl;
    }
#ifdef XOPENME
    xopenme_clock_end(X_TIMER_CLASSIFY);
#endif
    cout << "OK: Image classified" << endl;

    // Process results
    const int output_size = 1000;
    const size_t num_results = 5;
    const float threshold = 0.0001f;
    vector<pair<float, int>> top_results;
    // TODO
    cout << "GET TOP RESULTS HERE" << endl;

    // Read labels
    vector<string> labels;
    ifstream file(labels_file);
    string line;
    while (getline(file, line))
      labels.push_back(line);

    // Print predictions
    cout << "---------- Prediction for " << image_file << " ----------" << endl;
    for (const auto& result : top_results) {
      const float confidence = result.first;
      const int index = result.second;
      cout << fixed << setprecision(4) << confidence 
        << " - \"" << labels[index] << " (" << index << ")\"" << endl;
    }

#ifdef XOPENME
    xopenme_dump_state();
    xopenme_finish();
#endif    
  }
  catch (const string& error_message) {
    cout << "ERROR: " << error_message << endl;
    return -1;
  }
  return 0;
}
