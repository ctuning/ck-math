gemmlowp: a small self-contained low-precision GEMM library
gemmlowp's main public interface is in the public/ subdirectory.
This is a headers-only library, so there is nothing to link to.

To use it, add 
    
    ${CK_FLAG_PREFIX_INCLUDE}${CK_ENV_LIB_GEMMLOWP_INCLUDE }

to the list of your compiler options. 

Or add CK_ENV_LIB_GEMMLOWP_INCLUDE to compiler_add_include_as_env_from_deps array:

    "compiler_add_include_as_env_from_deps": [
      "CK_ENV_LIB_GEMMLOWP_INCLUDE "
    ] 
