# This package can be built in 4 different modes:

ck install package --tags=armcl,viascons    # vanilla/reference CPU version

ck install package --tags=armcl,viascons --env.USE_NEON=1 --extra_tags=vneon --extra_path=-neon                                     # only NEON support

ck install package --tags=armcl,viascons --env.USE_OPENCL=1 --extra_tags=vopencl --extra_path=-opencl                               # only OPENCL support

ck install package --tags=armcl,viascons --env.USE_NEON=1 --env.USE_OPENCL=1 --extra_tags=vneon,vopencl --extra_path=-neon-opencl   # both NEON and OPENCL
