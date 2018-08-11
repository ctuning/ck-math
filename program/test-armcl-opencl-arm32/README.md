# `test-armcl-opencl-arm32`

The `test-armcl-opencl` and `test-armcl-opencl-arm32` programs provide a
convenient interface to executables built along the Arm Compute Library
(ArmCL). Moreover, they provide a means to rebuild an ArmCL instance using its
native (SCons-based) build system. This is useful when the CK build system lags
behind the native one, as well as for testing.

In what follows, we assume that commands get executed from the program's folder.
Please either change to this directory:
```
$ cd `ck find program:test-armcl-opencl-arm32`
$ ck compile
```
or specify the entry explicitly e.g.:
```
$ ck compile program:test-armcl-opencl-arm32
```

## (Re-)Build

To rebuild an ArmCL instance, run the following:
```
$ ck compile
```
and select the ArmCL instance to be rebuilt.

## Run

To run one of the ArmCL executables, run the following:
```
$ ck run
```
and select one of the listed commands (the list may well be out-of-date):

```
0) benchmark-opencl-alexnet (../ck-benchmark-opencl$#script_ext#$)
1) benchmark-opencl-googlenet (../ck-benchmark-opencl$#script_ext#$)
2) benchmark-opencl-mobilenet (../ck-benchmark-opencl$#script_ext#$)
3) benchmark-opencl-squeezenet (../ck-benchmark-opencl$#script_ext#$)
4) benchmark-opencl-vgg16 (../ck-benchmark-opencl$#script_ext#$)
5) benchmark-opencl-vgg19 (../ck-benchmark-opencl$#script_ext#$)
6) help-benchmark (LD_LIBRARY_PATH=${CK_ENV_LIB_ARMCL_SRC}/build:${LD_LIBRARY_PATH} ${EXECUTABLE} --help)
7) help-validation (LD_LIBRARY_PATH=${CK_ENV_LIB_ARMCL_SRC}/build:${LD_LIBRARY_PATH} ${EXECUTABLE} --help)
8) list-tests-benchmark (../ck-run$#script_ext#$ --list-tests)
9) list-tests-validation (../ck-run$#script_ext#$ --list-tests)
10) run-benchmark (../ck-run$#script_ext#$)
11) run-opencl-alexnet (../ck-run-opencl$#script_ext#$)
12) run-opencl-googlenet (../ck-run-opencl$#script_ext#$)
13) run-opencl-mobilenet (../ck-run-opencl$#script_ext#$)
14) run-opencl-squeezenet (../ck-run-opencl$#script_ext#$)
15) run-opencl-vgg16 (../ck-run-opencl$#script_ext#$)
16) run-opencl-vgg19 (../ck-run-opencl$#script_ext#$)
17) run-validation (../ck-run$#script_ext#$)
```

**NB:** CK will use the latest ArmCL instance compiled with `ck compile`.

Below we describe what the commands are for and how we recommend to use them.

### Benchmarking ArmCL-OpenCL examples (from ArmCL v18.0x)

To benchmark one of the ArmCL graph examples (`benchmark-opencl-*`), please run:

```
$ ck benchmark --repetitions=1
```

This group of commands is to execute the `benchmark_graph_*` executables at the
highest CPU and GPU frequencies.  The selected executable is run with
`--instruments=${INSTRUMENTS}`, `--iterations=${ITERATIONS}`, and
`--example_args=${ARGS}`, where the variables are currently hardcoded for each
command to:
- `INSTRUMENTS=WALL_CLOCK_TIMER_MS,OPENCL_TIMER_MS` (collect wall clock and kernel execution time in milliseconds);
- `ITERATIONS=10` (repeat 10 times);
- `ARGS=1` (use OpenCL).

The run results are available in `tmp/tmp-stdout.tmp`.

**NB:** CK will offer the available ArmCL instances. If you select an instance
that has been previously (re)built with `ck compile`, SCons will be quick to
realise that; otherwise, you will be in for a potentially long (re)building.

**NB:** CK will only run the executable once (`--repetitions=1`) externally,
however, the executable will run the graph `${ITERATIONS}` times internally.

### Running ArmCL-OpenCL examples (before ArmCL v18.0x)

To test one of the ArmCL graph examples (`run-opencl-*`), please run:

```
$ ck run
```

This group of commands is for less recent versions of ArmCL that lack internal
instrumentation support.  The output is less than exciting so you may wish to
try the following.

To execute the `graph_*` executables at the highest CPU and GPU frequencies
with [dividiti's OpenCL profiler](https://github.com/dividiti/dvdt-prof),
please run:

```
$ ck benchmark --repetitions=1 --dvdt_prof
```

The profiler results are available in `tmp/tmp-dvdt-prof*.json`, but may not be easy to parse.

**NB:** You may want to install the profiler from the following package:
```
$ ck install package:tool-dvdt-prof-cjson-master-universal
```


### Printing help messages

```
$ ck run --cmd_key=help-benchmark
$ ck run --cmd_key=help-validation
```

### Listing all tests

```
$ ck run --cmd_key=list-tests-benchmark
$ ck run --cmd_key=list-tests-validation
```

### Filtering out validation tests (examples)

```
$ ck run --cmd_key=run_validation \
  --env.FILTER='CL/SoftmaxLayer/Float/FP\\d\\d/RunSmall@Shape=633x11x3x5'
```

```
$ ck run --cmd_key=run-validation \
  --env.FILTER='CL/DirectConvolutionLayer/Float/FP32/Run@InputShape=33x35x8x8:StrideX=1:StrideY=1:PadX=0:PadY=0:KernelSize=1'
```
