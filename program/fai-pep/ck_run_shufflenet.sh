#!/bin/bash

cd ${CK_ENV_BENCH_FAI_PEP}

${CK_ENV_COMPILER_PYTHON_FILE} benchmarking/run_bench.py -b specifications/models/caffe2/shufflenet/shufflenet.json