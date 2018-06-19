Eigen is a C++ template library for linear algebra: matrices, vectors, numerical solvers, and related algorithms.

To use it, add 
    
    ${CK_FLAG_PREFIX_INCLUDE}${CK_ENV_LIB_EIGEN}

to the list of your compiler options. 

Or add CK_ENV_LIB_EIGEN to compiler_add_include_as_env_from_deps array:

    "compiler_add_include_as_env_from_deps": [
      "CK_ENV_LIB_EIGEN"
    ] 
