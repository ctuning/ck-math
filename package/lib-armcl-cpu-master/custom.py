#
# Developers: Grigori Fursin, cTuning foundation
#             Anton Lokhmotov, dividiti
#

import os
import sys
import json
import re
import collections
import errno

##############################################################################
def pre_path(i):
    tags=i['tags']
    env=i.get('install_env',{})

    # Add tags depending on env
    if env.get('USE_OPENCL','').lower()=='on' and 'vopencl' not in tags: tags.append('vopencl')
    if env.get('USE_NEON','').lower()=='on' and 'vneon' not in tags: tags.append('vneon')
    if env.get('USE_GRAPH','').lower()=='on' and 'vgraph' not in tags: tags.append('vgraph')

    return {'return':0}

##############################################################################
def file_get_contents(filename):
    return open(filename).read()

def resolve_includes(target, source, lpath):
    # File collection
    FileEntry = collections.namedtuple('FileEntry', 'target_name file_contents')
    # Include pattern
    pattern = re.compile("#include \"(.*)\"")

    # Get file contents
    files = []
    for s in source:
        name = s.split("/")[-1]
        s_absp = lpath +'/src/'+ s
        mycontents = file_get_contents(s_absp)
        contents=mycontents.splitlines()
        embed_target_name = s_absp + "embed"
        entry = FileEntry(target_name=embed_target_name, file_contents=contents)
        files.append((name,entry))

    # Create dictionary of tupled list
    files_dict = dict(files)

    # Check for includes (can only be files in the same folder)
    final_files = []
    for file in files:
        done = False
        tmp_file = file[1].file_contents
        while not done:
            file_count = 0
            updated_file = []
            for line in tmp_file:
                found = pattern.search(line)
                if found:
                    include_file = found.group(1)
                    if include_file in files_dict:
                       data = files_dict[include_file].file_contents
                       updated_file.extend(data)
                else:
                    updated_file.append(line)
                    file_count += 1

            # Check if all include are replaced.
            if file_count == len(tmp_file):
                done = True

            # Update temp file
            tmp_file = updated_file

        # Append and prepend string literal identifiers and add expanded file to final list
        tmp_file.insert(0, "R\"(\n")
        tmp_file.append("\n)\"")
        entry = FileEntry(target_name=file[1].target_name, file_contents=tmp_file)
        final_files.append((file[0], entry))

    # Write output files
    for file in final_files:
        with open(file[1].target_name, 'w+') as out_file:
            contents = file[1].file_contents
            for line in contents:
                out_file.write("%s\n" % line)

def setup(i):
    """
    Input:  {
              cfg              - meta of the soft entry
              self_cfg         - meta of module soft
              ck_kernel        - import CK kernel module (to reuse functions)

              host_os_uoa      - host OS UOA
              host_os_uid      - host OS UID
              host_os_dict     - host OS meta

              target_os_uoa    - target OS UOA
              target_os_uid    - target OS UID
              target_os_dict   - target OS meta

              target_device_id - target device ID (if via ADB)

              tags             - list of tags used to search this entry

              env              - updated environment vars from meta
              customize        - updated customize vars from meta

              deps             - resolved dependencies for this soft

              interactive      - if 'yes', can ask questions, otherwise quiet

              path             - path to entry (with scripts)
              install_path     - installation path
            }

    Output: {
              return        - return code =  0, if successful
                                          >  0, if error
              (error)       - error text if return > 0

              (install_env) - prepare environment to be used before the install script
            }

    """

    import os
    import shutil
    import glob

    # Get variables
    o=i.get('out','')

    ck=i['ck_kernel']

    hos=i['host_os_uoa']
    tos=i['target_os_uoa']

    hosd=i['host_os_dict']
    tosd=i['target_os_dict']

    hbits=hosd.get('bits','')
    tbits=tosd.get('bits','')

    hname=hosd.get('ck_name','')    # win, linux
    hname2=hosd.get('ck_name2','')  # win, mingw, linux, android
    tname2=tosd.get('ck_name2','')  # win, mingw, linux, android

    macos=hosd.get('macos','')      # yes/no

    hft=i.get('features',{}) # host platform features
    habi=hft.get('os',{}).get('abi','') # host ABI (only for ARM-based); if you want to get target ABI, use tosd ...
                                        # armv7l, etc...

    p=i['path']

    env=i['new_env']

    pi=i.get('install_path','')

    cus=i['customize']
    ie=cus.get('install_env',{})
    nie={} # new env

    deps=i.get('deps','')

    # Check if reference lib or customized (with opts)
    lib_id=cus.get('lib_id',0) # check from already installed

    y=env.get('NNTEST_LIB_ID','')
    if y!='':
       lib_id=int(env['NNTEST_LIB_ID'])
    else:
       x=env.get('PACKAGE_URL','')
       if x!='' and 'ARM-software' not in x:
          lib_id=1

    cus['lib_id']=lib_id

    # Converting sconscript to CK format
    flags = ['-D_GLIBCXX_USE_NANOSLEEP','-Wno-deprecated-declarations','-Wall','-DARCH_ARM',
         '-Wextra','-Wno-unused-parameter','-pedantic','-Wdisabled-optimization','-Wformat=2',
         '-Winit-self','-Wstrict-overflow=2','-Wswitch-default',
         '-fpermissive','-std=gnu++11','-Wno-vla','-Woverloaded-virtual',
         '-Wctor-dtor-privacy','-Wsign-promo','-Weffc++','-Wno-format-nonliteral','-Wno-overlength-strings','-Wno-strict-overflow']

    lcore_flags=['-ldl']
    lflags=['-ldl']

    # Check various target params from CK
    cpu_features=tosd.get('cpu_features',{})
    tneon=cpu_features.get('arm_fp_neon','')
    thardfp=cpu_features.get('arm_fp_hard','')

    tabi=tosd.get('abi','')
    if tabi=='': # Means host
       tabi=habi # Means ARM
       if tabi=='': # Means x86 (indirectly)
          tabi='x86'
          if str(tbits)=='64': tabi='x86_64'

    if 'x86' in tabi:
       flags+=['-fPIC']

    neon=False
    if env.get('USE_NEON','').lower()=='on' or tneon=='yes':
       neon=True
       nie['USE_NEON']='ON'
       flags += ['-I../arm_compute/core/NEON/kernels/winograd']
       flags += ['-I../arm_compute/core/NEON/kernels/assembly']

    if env.get('WERROR','').lower()=='on':
       flags+=['-Werror']

    flags += ['-I../include']

    opencl=False
    if env.get('USE_OPENCL','').lower()=='on':
       opencl=True
       nie['USE_OPENCL']='ON'
       openclenv = deps['opencl']['dict'].get('customize')
#       ck.debug_out(openclenv)
       ipath = openclenv.get('path_include')
       lpath = openclenv.get('path_lib')
#       flags += ['-I'+ipath] ACL uses local CL/cl.h cl2.h
#       nie['CK_FLAG_PREFIX_INCLUDE'] = ''
       lflags +=['-L'+lpath+' -lOpenCL']
#       lcore_flags += ['']
       if env.get('USE_EMBEDDED_KERNELS','').lower()=='on':
           flags += ['-DEMBEDDED_KERNELS']

    use_graph=env.get('USE_GRAPH','').lower()
    if use_graph=='on' and not (opencl and neon):
       return {'return':1, 'error':'USE_GRAPH requires both USE_OPENCL and USE_NEON'}

    hardfp=False
    if env.get('USE_BARE_METAL','').lower()=='on' or thardfp=='yes':
       hardfp=True
       nie['USE_BARE_METAL']='ON'

#    if env.get('USE_VALIDATION_TEST','').lower()=='on':
#       print "VALIDATION"

#    if env.get('USE_BENCHMARK_TEST','').lower()=='on':
#       print "BENCHMARK"


    if neon and 'x86' in tabi:
       return {'return':1, 'error':'Cannot compile NEON for x86'}


    compiler_env=deps['compiler'].get('dict',{}).get('env',{})
    compiler_ver=deps['compiler'].get('ver','')
    compiler_ver_list=deps['compiler'].get('dict',{}).get('customize',{}).get('version_split',[])

    if len(compiler_ver_list)>0 and compiler_ver_list[0]>=6:
       # there is a proper way in the CK to compare that version >= 6.1 now
       flags+=['-Wno-ignored-attributes']

    if compiler_ver == '4.8.3':
       flags+=['-Wno-array-bounds']

    cxx=compiler_env['CK_CXX']

    if compiler_env.get('CK_ENV_LIB_STDCPP_INCLUDE','')!='':
       flags+=['-I'+compiler_env['CK_ENV_LIB_STDCPP_INCLUDE']]
    if compiler_env.get('CK_ENV_LIB_STDCPP_INCLUDE_EXTRA','')!='':
       flags+=['-I'+compiler_env['CK_ENV_LIB_STDCPP_INCLUDE_EXTRA']]
#       env['CK_ENV_LIB_STDCPP_STATIC']=libstdcpppath+sep+'libgnustl_static.a'
#       env['CK_ENV_LIB_STDCPP_DYNAMIC']=libstdcpppath+sep+'libgnustl_shared.so'
#       env['CK_ENV_LIB_STDCPP_INCLUDE_EXTRA']=libstdcpppath+sep+'include'


    if 'clang++' in cxx:
       flags += ['-Wno-format-nonliteral','-Wno-deprecated-increment-bool','-Wno-vla-extension','-Wno-mismatched-tags']
    elif 'g++' in cxx:
       flags += ['-Wlogical-op','-Wnoexcept','-Wstrict-null-sentinel']

    if env.get('USE_CPPTHREADS','').lower()=='on':
        flags += ['-DARM_COMPUTE_CPP_SCHEDULER=1']

    if env.get('USE_OPENMP','').lower()=='on':
        if 'clang++' in cxx:
            return {'return':1, 'error':'Clang does not support OpenMP. Use --env.USE_CPPTHREADS=ON'}

        flags += ['-DARM_COMPUTE_OPENMP_SCHEDULER=1','-fopenmp']
        lflags += ['-fopenmp']
        lcore_flags += ['-fopenmp']

    def use_arm_v7():
        if ('v7a' in tabi) or ('v7l' in tabi):
            return True
        elif 'arm64' in tabi or 'aarch64' in tabi:
            if tbits == '32':
                return True
        return False

    if use_arm_v7():
        env['USE_ARM32']='ON'
        flags += ['-march=armv7-a','-mthumb','-mfpu=neon']

        if hardfp:
            flags += ['-mfloat-abi=hard']
        elif tname2=='android':
            flags += ['-mfloat-abi=softfp']
    elif env.get('USE_ARM64_V82A','').lower()=='on':
        env['USE_ARM64']='ON'
        flags += ['-march=armv8.2-a+fp16+simd']
        flags += ['-DARM_COMPUTE_ENABLE_FP16']
        flags += ['-DARM_COMPUTE_AARCH64_V8_2', '-DNO_DOT_IN_TOOLCHAIN']
    elif 'arm64' in tabi or 'aarch64' in tabi:
        env['USE_ARM64']='ON'
        flags += ['-march=armv8-a']
        flags += ['-DARM_COMPUTE_AARCH64_V8A', '-DNO_DOT_IN_TOOLCHAIN']
    elif tabi=='x86':
        flags += ['-m32']
    elif tabi=='x86_64':
        flags += ['-m64']

    if tname2=='android':
        flags += ['-DANDROID']
    elif env.get('USE_BARE_METAL','').lower()=='on':
        flags += ['-fPIC','-DNO_MULTI_THREADING']
        lflags+=['-static']
        lcore_flags+=['-static']
    else:
        lflags += ['-lpthread']

    if env.get('DEBUG','').lower()=='on':
       env['ASSERTS']='ON'
       flags+=['-O0','-g','-gdwarf-2', '-DARM_COMPUTE_DEBUG_ENABLED']
    else:
       flags += ['-O3','-ftree-vectorize']

    if env.get('ASSERTS','').lower()=='on':
       flags += ['-DARM_COMPUTE_ASSERTS_ENABLED','-fstack-protector-strong']

    if env.get('CK_ARMCL_EXTRA_CXX_FLAGS','')!='':
       flags.append(env['CK_ARMCL_EXTRA_CXX_FLAGS'])

    if env.get('CK_SKIP_FPIC','').lower()!='on':
       if '-fPIC' not in flags:
          flags.append('-fPIC')

    nie['CXXFLAGS']=' '.join(flags)
    nie['LFLAGS']=' '.join(lflags)
    nie['LCORE_FLAGS']=' '.join(lcore_flags)

    return {'return':0, 'install_env':nie}

##############################################################################
# customize installation after download

def _slash(s):
    return s.replace('\\','/')

def post_setup(i):
    """
    Input:  {
              The same as in setup(i)

              new_env - last env (can be directly updated)
            }

    Output: {
              return        - return code =  0, if successful
                                          >  0, if error
              (error)       - error text if return > 0
            }

    """

    import os
    import shutil
    import glob
    import subprocess

    # Get variables
    o=i.get('out','')

    ck=i['ck_kernel']

    cfg=i.get('cfg',{})
    hosd=i['host_os_dict']
    tosd=i['target_os_dict']

    winh=hosd.get('windows_base','')

    eset=hosd.get('env_set','')
    eifs=hosd.get('env_quotes_if_space','')
    sext=hosd.get('script_ext','')

    hname=hosd.get('ck_name','')    # win, linux
    hname2=hosd.get('ck_name2','')  # win, mingw, linux, android
    tname2=tosd.get('ck_name2','')  # win, mingw, linux, android

    env=i.get('new_env',{})

    deps=i.get('deps',{})
    pi=i.get('install_path','')
    libprefix=''
    if winh!='yes' or tname2=='android':
       libprefix='lib'

    compiler_env=deps['compiler'].get('dict',{}).get('env',{})
    obj_ext=compiler_env.get('CK_OBJ_EXT')

    flags=env.get('CXXFLAGS','')
    lflags=env.get('LFLAGS','')
    lcore_flags=env.get('LCORE_FLAGS','')
    bare_metal=env.get('USE_BARE_METAL','').lower()
    use_neon=env.get('USE_NEON','').lower()
    use_opencl= env.get('USE_OPENCL','').lower()
    use_embed_kernel= env.get('USE_EMBEDDED_KERNELS','').lower()
    use_graph=env.get('USE_GRAPH','').lower()

    pp=i.get('script_path','')
    if pp=='':
       pp=i.get('path_original_package','')

    pi=i.get('install_path','')
    pi1=cfg.get('customize',{}).get('extra_dir','')
    if pi1=='': pi1=cfg.get('customize',{}).get('git_src_dir','')

    build_dir=pi
    if pi1!='': build_dir=os.path.join(pi,pi1)

    if not os.path.isdir(build_dir):
       return {'return':1, 'error':'Something is wrong - build directory is not there ('+build_dir+')'}

    os.chdir(build_dir)

    xcore_files = glob.glob('src/core/*.cpp')
    xcore_files += glob.glob('src/core/CPP/*.cpp')
    xcore_files += glob.glob('src/core/CPP/kernels/*.cpp')
    xcore_files += glob.glob('src/core/utils/*/*.cpp')

    xfiles = glob.glob('src/runtime/*.cpp')
    xfiles += glob.glob('src/runtime/CPP/ICPPSimpleFunction.cpp')
    xfiles += glob.glob('src/runtime/CPP/functions/*.cpp')

    # CLHarrisCorners uses the Scheduler to run CPP kernels
    xfiles += glob.glob('src/runtime/CPP/SingleThreadScheduler.cpp')

    embed_files = []
    files_to_delete = []

    if bare_metal=='on':
       if env.get('USE_CPPTHREADS','').lower()=='on' or env.get('USE_OPENMP','').lower()=='on':
          return {'return':1, 'error':'OpenMP and C++11 threads not supported in bare_metal. use --env.USE_CPPTHREADS=OFF --env.USE_OPENMP=OFF'}
    else:
        if env.get('USE_CPPTHREADS','').lower()=='on':
             xfiles += glob.glob('src/runtime/CPP/CPPScheduler.cpp')
        if env.get('USE_OPENMP','').lower()=='on':
             xfiles += glob.glob('src/runtime/OMP/OMPScheduler.cpp')

    if use_opencl=='on':
       xcore_files += glob.glob('src/core/CL/*.cpp')
       xcore_files += glob.glob('src/core/CL/kernels/*.cpp')
       xfiles += glob.glob('src/runtime/CL/*.cpp')
       xfiles += glob.glob('src/runtime/CL/functions/*.cpp')

       # v18.05
       xfiles += glob.glob('src/runtime/CL/tuners/*.cpp')

       if use_embed_kernel == 'on':
          cl_files  = glob.glob('src/core/CL/cl_kernels/*.cl') + glob.glob('src/core/CL/cl_kernels/*.h')
          source_list = []
          for file in cl_files:
              source_name = file
              source_list.append(source_name)
              embed_files.append(source_name + "embed")
#          generate_embed = env.Command(embed_files, source_list, action=resolve_includes)
          generate_embed = resolve_includes(embed_files, source_list, pi)
          #Default(generate_embed)
          files_to_delete += embed_files

    if use_neon=='on':
        xcore_files += glob.glob('src/core/NEON/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/*.cpp')
        # v18.08
        xcore_files += glob.glob('src/core/NEON/kernels/assembly/*.cpp')
        xfiles += glob.glob('src/runtime/NEON/functions/assembly/*.cpp')
        # v18.05
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a32_sgemm_8x6/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_gemm_s16_12x8/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_gemm_s8_12x8/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_gemm_s8_4x4/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_gemm_u16_12x8/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_gemm_u8_12x8/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_gemm_u8_4x4/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_hgemm_24x8/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_sgemm_12x8/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_sgemm_native_16x4/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_sgemv_pretransposed/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/arm_gemm/kernels/a64_sgemv_trans/*.cpp')
        # v18.01
        xcore_files += glob.glob('src/core/NEON/kernels/winograd/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/winograd/transforms/*.cpp')
        # v18.0x
        xcore_files += glob.glob('src/core/NEON/kernels/convolution/winograd/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/convolution/winograd/transforms/*.cpp')
        xcore_files += glob.glob('src/core/NEON/kernels/convolution/depthwise/*.cpp')

        if env.get('USE_ARM32','').lower()=='on':
           xcore_files += glob.glob('src/core/NEON/kernels/arm32/*.cpp')
        elif env.get('USE_ARM64','').lower()=='on':
           xcore_files += glob.glob('src/core/NEON/kernels/arm64/*.cpp')

        xfiles += glob.glob('src/runtime/NEON/*.cpp')
        xfiles += glob.glob('src/runtime/NEON/functions/*.cpp')

    if use_graph=='on':
        if use_neon!='on' or use_opencl!='on':
            return {'return':1, 'error':'USE_GRAPH requires both USE_OPENCL and USE_NEON'}

        xgraph_files = glob.glob('src/graph/*.cpp')
        xgraph_files += glob.glob('src/graph/*/*.cpp')
        # v18.05
        xgraph_files += glob.glob('src/graph/backends/CL/*.cpp')
        xgraph_files += glob.glob('src/graph/backends/NEON/*.cpp')
        


        # for the sake of simplicity just add Graph API into the main lib for now
        xfiles += xgraph_files

    # Generate string with build options library version to embed in the library:
    r=ck.run_and_get_stdout({'cmd':['git','rev-parse','HEAD']})
    if r['return']==0 and r['return_code']==0:
       git_hash=r['stdout'].strip()

    version_filename = 'arm_compute_version.embed' #"%s/arm_compute_version.embed" % os.path.dirname(glob.glob("src/core/*")[0].rrstr())
    build_info = "\"arm_compute_version=%s Build options: %s Git hash=%s\"" % ('', '', git_hash.strip())

    r=ck.save_text_file({'text_file':version_filename, 'string':build_info})
    if r['return']>0: return r

    # BUILDING CORE LIB **************************************************************
    # Clean up files and prepare obj names
    core_files=''

    for f in xcore_files:
        f=_slash(f) # fix windows names
        fo=os.path.splitext(f)[0]+obj_ext
        core_files+=' ../'+f

    # Compiler env
    sb=hosd.get('batch_prefix','')+'\n'

    sb+=deps.get('compiler',{}).get('bat','')+'\n'

    x=env.get('CK_AUTOTUNE','').lower()
    if x=='yes' or x=='on':
       flags+=' -DCK_AUTOTUNE=ON'

    sb+=eset+' INSTALL_DIR='+_slash(pi)+'\n\n'
    sb+=eset+' BUILD_DIR='+_slash(build_dir)+'\n\n'
    sb+=eset+' CK_CXXFLAGS='+_slash(eifs+flags+eifs)+'\n'
    sb+=eset+' CK_LFLAGS='+_slash(eifs+lcore_flags+eifs)+'\n'
    sb+=eset+' CK_SRC_FILES='+_slash(eifs+core_files+eifs)+'\n'
    sb+=eset+' CK_TARGET_LIB='+_slash(libprefix)+'arm_compute_core\n'
    sb+=eset+' CK_BARE_METAL='+bare_metal+'\n'
    sb+=eset+' ORIGINAL_PACKAGE_DIR='+_slash(pp)+'\n\n'
    sb+=eset+' CK_HOST_CPU_NUMBER_OF_PROCESSORS='+str(env.get('CK_HOST_CPU_NUMBER_OF_PROCESSORS', 1))+'\n\n'

    rest_params_var = '%*' if hname == 'win' else '$@'
    sb+=hosd.get('env_call','')+' '+os.path.join(pp,'build'+sext) + ' ' + rest_params_var

    # Prepare build script
    fn=os.path.join(pi, 'build_core' + sext)
    try:
        os.makedirs(os.path.dirname(fn))
    except OSError as exc:
        if exc.errno != errno.EEXIST:
            raise

    rx=ck.save_text_file({'text_file':fn, 'string':sb})
    if rx['return']>0: return rx

    # Check if need to set executable flags
    se=hosd.get('set_executable','')
    if se!='':
       x=se+' '+fn
       rx=os.system(x)

    # Run script
    rx=os.system(fn)

    if rx>1:
       return {'return':1, 'error':'ARMCL build failed'}

    # BUILDING CORE + RUNTIME LIB **************************************************************
    # Clean up files and prepare obj names
    files=''
    for f in xfiles:
        f=_slash(f) # fix windows names
        fo=os.path.splitext(f)[0]+obj_ext
        files+=' ../'+f

    # Compiler env
    sb=hosd.get('batch_prefix','')+'\n'

    sb+=deps.get('compiler',{}).get('bat','')+'\n'

    sb+=eset+' INSTALL_DIR='+_slash(pi)+'\n\n'
    sb+=eset+' BUILD_DIR='+_slash(build_dir)+'\n\n'
    sb+=eset+' CK_CXXFLAGS='+_slash(eifs+flags+eifs)+'\n'
    sb+=eset+' CK_LFLAGS='+_slash(eifs+lflags+eifs)+'\n'
    sb+=eset+' CK_SRC_FILES='+_slash(eifs+files+eifs)+'\n'
    sb+=eset+' CK_TARGET_LIB='+_slash(libprefix)+'arm_compute\n'
    sb+=eset+' CK_BARE_METAL='+bare_metal+'\n'
    sb+=eset+' ARMCL_EXTRA_LIB=-larm_compute_core\n'
    sb+=eset+' ORIGINAL_PACKAGE_DIR='+_slash(pp)+'\n\n'
    sb+=eset+' CK_HOST_CPU_NUMBER_OF_PROCESSORS='+str(env.get('CK_HOST_CPU_NUMBER_OF_PROCESSORS', 1))+'\n\n'

    sb+=hosd.get('env_call','')+' '+os.path.join(pp,'build'+sext) + ' ' + rest_params_var

    # Prepare build script
    fn=os.path.join(pi, 'build' + sext)
    try:
        os.makedirs(os.path.dirname(fn))
    except OSError as exc:
        if exc.errno != errno.EEXIST:
            raise

    rx=ck.save_text_file({'text_file':fn, 'string':sb})
    if rx['return']>0: return rx

    # Check if need to set executable flags
    se=hosd.get('set_executable','')
    if se!='':
       x=se+' '+fn
       rx=os.system(x)

    # Run script
    rx=os.system(fn)

    if rx>1:
       return {'return':1, 'error':'ARMCL build failed'}

    return {'return':0}
