We do not compile Fortran API and LAPACK by default.

To customize build use the following vars:

* OPENBLAS_TARGET (str) to force target
* OPENBLAS_FORTRAN (YES) to build Fortran API
* OPENBLAS_LAPACK (YES) to build lapack

For example:
```
$ ck install package:lib-openblas-0.3.0-universal --env.OPENBLAS_TARGET=ARMV7 --env.OPENBLAS_FORTRAN=YES --env.OPENBLAS_LAPACK=YES
```
