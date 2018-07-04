
# Classification program for ArmCL

## Requirements

Extra CK repositories:
```
$ ck pull repo:ck-tensorflow
$ ck pull repo --url=https://github.com/dividiti/ck-request-asplos18-mobilenets-armcl-opencl
```

### ArmCL library
To build this program, you need ArmCL compiled with Graph API:

```
$ ck install package:lib-armcl-opencl-18.05 --env.USE_GRAPH=ON --env.USE_NEON=ON --extra_version=-graph [--target_os=android23-arm64]
```

To build this program for Android you need to embedd kernels and select target API as follows:
```
$ ck install package:lib-armcl-opencl-18.05 --env.USE_GRAPH=ON --env.USE_NEON=ON --extra_version=-graph --env.USE_EMBEDDED_KERNELS=ON --env.DEBUG=ON --target_os=android23-arm64
```

**NB:** Use `--target_os=android23-arm64` to build for Android API 23 (v6.0 "Marshmallow") or [similar](https://source.android.com/setup/start/build-numbers).

### Weights package

Install a package providing weights as NumPy array files:

```
$ ck install package:weights-mobilenet-v1-1.0-224-npy
$ ck install package --tags=mobilenet,weights,npy
```

## Compile

```
$ ck compile program:armcl-classification-mobilenet [--target_os=android23-arm64]
```

## Run

```
$ ck run program:armcl-classification-mobilenet [--target_os=android23-arm64]
```
