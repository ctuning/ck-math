/*
 * Copyright (c) 2018 cTuning foundation.
 * See CK COPYRIGHT.txt for copyright details.
 *
 * SPDX-License-Identifier: BSD-3-Clause.
 * See CK LICENSE.txt for licensing details.
 */

#pragma once

#include <algorithm>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <queue>
#include <string>
#include <vector>

#include <stdlib.h>

#ifdef XOPENME
#include <xopenme.h>
#endif

namespace CK {
namespace ClassificationDemo {

enum X_TIMERS {
  X_TIMER_SETUP,
  X_TIMER_LOAD_IMAGE,
  X_TIMER_CLASSIFY,

  X_TIMER_COUNT
}; 

bool get_arg(const char* arg, const char* key, std::string& target) {
  if (strncmp(arg, key, strlen(key)) == 0) {
    target = &arg[strlen(key)];
    return true;
  }
  return false;
}

void check_file(const std::string& path, const std::string& id) {
  if (path.empty())
    throw id + " file path is not specified";
  if (!std::ifstream(path).good())
    throw id + " file can't be opened, check if it exists";
  std::cout << id << " file: " << path << std::endl;
}

inline void init_demo() {
#ifdef XOPENME
  xopenme_init(X_TIMER_COUNT, 0);
#endif
}

inline void finish_demo() {
#ifdef XOPENME
  xopenme_dump_state();
  xopenme_finish();
#endif    
}

template <typename TFunction>
void measure_setup(TFunction&& function) {
#ifdef XOPENME
  xopenme_clock_start(X_TIMER_SETUP);
#endif

  function();
  
#ifdef XOPENME
    xopenme_clock_end(X_TIMER_SETUP);
#endif
}

template <typename TFunction>
void measure_load_image(TFunction&& function) {
#ifdef XOPENME
  xopenme_clock_start(X_TIMER_LOAD_IMAGE);
#endif

  function();
  
#ifdef XOPENME
  xopenme_clock_end(X_TIMER_LOAD_IMAGE);
#endif
}

template <typename TFunction>
void measure_classify(TFunction&& function) {
  auto cout_str = getenv("CT_REPEAT_MAIN");
  int count = cout_str ? atol(cout_str) : 1;
  
#ifdef XOPENME
  xopenme_clock_start(X_TIMER_CLASSIFY);
#endif

  for (int i = 0; i < count; i++) {
    function();
  }
  
#ifdef XOPENME
  xopenme_clock_end(X_TIMER_CLASSIFY);
#endif
}

typedef std::pair<float, int> Probe;
typedef std::vector<Probe> Probes;
typedef std::vector<std::string> Labels;

inline Probes get_top_n(std::vector<float> predictions, size_t top_n, bool skip_first) {
  std::priority_queue<Probe, Probes, std::greater<Probe>> top_result;
  for (int i = skip_first ? 1 : 0; i < predictions.size(); i++) {
    top_result.push({predictions[i], i});
    // Remove smallest value when required count is achieved
    if (top_result.size() > top_n) top_result.pop();
  }
  Probes probes;
  while (!top_result.empty()) {
    probes.insert(probes.begin(), top_result.top());
    top_result.pop();
  }
  return probes;
}

Labels load_labels(const std::string& labels_file) {
  Labels labels;
  std::ifstream file(labels_file);
  std::string line;
  while (std::getline(file, line))
    labels.push_back(line);
  return labels;
}

void print_predictions(const std::string& image_file,
                       const Probes& top_results,
                       const Labels& labels) {
  std::cout << "---------- Prediction for " << image_file << " ----------" << std::endl;
  for (const auto& result : top_results) {
    const float confidence = result.first;
    const int index = result.second;
    std::cout << std::fixed << std::setprecision(4) << confidence 
      << " - \"" << labels[index] << " (" << index << ")\"" << std::endl;
  }
}

} // ClassificationDemo
} // namespace CK
