
# System-level network classification and benchmarking

To build this program, you need ArmCL compiled with Graph API:

```
$ ck pull all
$ ck install package:lib-armcl-opencl-18.05 --env.USE_GRAPH=ON --env.USE_NEON=ON --extra_version=-graph
```

When this is done, compile and run the program as usual:

```
$ ck compile program:benchmark-armcl-opencl
$ ck run program:benchmark-armcl-opencl
```

You can run on different networks:

* `ck run --env.CK_NETWORK=alexnet` (this is the default)

* `ck run --env.CK_NETWORK=googlenet`

* `ck run --env.CK_NETWORK=squeezenet`
