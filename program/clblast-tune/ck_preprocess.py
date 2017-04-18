#
# Convert raw output of the Caffe 'time' command
# to the CK timing format.
#
# Developers:
#   - Grigori Fursin, cTuning foundation / dividiti, 2016
#   - Anton Lokhmotov, dividiti, 2016-2017
#

import json
import os
import re
import sys

import sys
import os.path
import glob
import argparse



#OPTIONS
# OpenCL vendor names and their short name
VENDOR_TRANSLATION_TABLE = {
  "GenuineIntel": "Intel",
  "Intel(R) Corporation": "Intel",
  "Advanced Micro Devices, Inc.": "AMD",
  "NVIDIA Corporation": "NVIDIA",
}


# Server storing a copy of the database
DATABASE_SERVER_URL = "https://raw.githubusercontent.com/CNugteren/CLBlast-database/master/database.json"
VERBOSE=0



def make(a, src, dest, tos, tdid, odepsi):
    r=ck.access({'action':'search','module_uoa':'env','tags':'clblast-tune', 'target_os':tos})
    if r['return']>0: return r
    lst=r['lst']
    muid=lst[0]['module_uid']
    duid=lst[0]['data_uid']
    r=ck.access({'action':'load','module_uoa':muid,'data_uoa':duid})
    if r['return']>0: return r

    odeps=r['dict']['deps']
    myk = a['deps']
    envd = {"CMAKE_CONFIG": "Release",
            "PACKAGE_AUTOGEN": "NO",
            "PACKAGE_BUILD_TYPE": "cmake",
	    "PACKAGE_CONFIGURE_FLAGS": "",
	    "PACKAGE_CONFIGURE_FLAGS_ANDROID": "-DBUILD_SHARED_LIBS=OFF",
	    "PACKAGE_CONFIGURE_FLAGS_LINUX": "",
	    "PACKAGE_CONFIGURE_FLAGS_WINDOWS": "",
	    "PACKAGE_GIT": "NO",
	    "PACKAGE_GIT_CHECKOUT": "development",
	    "PACKAGE_PATCH": "YES",
	    "PACKAGE_SKIP_CLEAN_INSTALL": "NO",
	    "PACKAGE_SKIP_CLEAN_OBJ": "YES",
	    "PACKAGE_SKIP_CLEAN_PACKAGE": "NO",
	    "PACKAGE_SKIP_CLEAN_SRC_DIR": "YES",
	    "PACKAGE_SKIP_CMAKE_TARGET": "NO",
	    "PACKAGE_SUB_DIR": "src",
	    "PACKAGE_SUB_DIR1": "src",
	    "PACKAGE_URL": "https://github.com/CNugteren/CLBlast"
    }
    print "[Make CLBLAST] copy kernels header from "+src +"to "+dest
    ii={'action':'install',
       'module_uoa':'package',
       'data_uoa':'lib-clblast-master-universal-tune',
       'target_os':tos,
       'device_id':tdid,
       'deps':odeps,
       'env':envd,
       'out':'con'
    }
    r=ck.access(ii)   
    #### API CK FOR COMPILATION
    #### MODIFY A RUN TIME SET PACKAGE_GIT
    print "asdads"
    #### Compile again
   
    return r


def ck_preprocess(i):
    ck=i['ck_kernel']
    del i['ck_kernel']
    rt=i['run_time']
    deps=i['deps']
    env=i.get('env',{})
    pass_to_make = i
    pli = i['misc']
       
        
    # Load both stderr and stdout. Concatenate into one list.
    # NB: This assumes that Caffe iterates only once (--iterations=1).
    # Otherwise, looping over the log would be required.

#    for target in VENDOR_TRANSLATION_TABLE:
#            if d["device_vendor"] == target:
#               d["device_vendor"] = VENDOR_TRANSLATION_TABLE[target]

    tos = pli['target_os_uoa']
    tdid = pli['device_id']
    adf=pli['add_to_features']
    compiler=adf['gpgpu'][0]['gpgpu_deps']['compiler']['uoa']
    print (json.dumps(i, indent=2))

    print tos, tdid
    #GET DEFAULT VALUE from CLBlast
    deps_cb= deps['lib-clblast']
    b=deps_cb['cus']
    pl = b['path_lib']
    bench="xgemm"
    bench +=".hpp"
    pl=pl.split("install")[0] #### VERIFY WITH INSTALL SCRIPT 
    pl_suff= "src/scripts/database/"
    pk=pl
    pk_suff="src/src/database/kernels/"
    pl += pl_suff
    pk += pk_suff
    print pl, pk
    sys.path.append(pl)
    ####
    import database.io as io
    import database.db as db
    import database.clblast as clblast
    import database.bests as bests
    import database.defaults as defaults

    best_filename="database_best.json"
    if not os.path.isfile(best_filename):
        print "[database] database_best.json not found"
        database_filename=pl+"database.json"
        if not os.path.isfile(database_filename):
            io.download_database(database_filename, DATABASE_SERVER_URL)
        else:
            print "[database] DB found" 
        if os.path.isfile(database_filename):
            database = io.load_database(database_filename)
        # Retrieves the best performing results
        print("[database] Calculating the best results per device/kernel...")
        database_best_results = bests.get_best_results(database)
        # Determines the defaults for other vendors and per vendor
        print("[database] Calculating the default values...")
        database_defaults = defaults.calculate_defaults(database, 0) #second args denotes VERBOSE or NOT
        database_best_results["sections"].extend(database_defaults["sections"])
        database_best_filename='database_best.json'
        io.save_database(database_best_results, database_best_filename)
        # Optionally outputs the database to disk
        #### TEST to get best and default param 
    else:
         print "[database] database_best.json found"
         print "[database] Loading ", best_filename
         database_best_results = json.loads(open(best_filename).read())
#    if 1:
#       print("[database] Producing a C++ database in current dir...")
#        clblast.print_cpp_database(database_best_results, src_new_kernels)

    best = database_best_results['sections']
    rr={}
    print "[Tuning] Checking new best configuration"
    FIND = 1 
    if FIND:
        
        print "[Tuning] Modify databese_best entries"

        print "[Tuning] Creating new kernels directory"

        cp = os.getcwd()
        src_new_kernels = cp+"/kernels_tmp"
        if not os.path.exists(src_new_kernels):
             os.makedirs(src_new_kernels)
        else:
            print "[Tuning] " +src_new_kernels+ " already exists"
        print "[Tuning] wrinting new kernel in "+src_new_kernels
        clblast.print_cpp_database(database_best_results, src_new_kernels)

        rr = make(pass_to_make,src_new_kernels, pk, tos , tdid, "ciao")
        
    else:
        print "[Tuning] Nothing to do"
        print "[Tuning] Exit"
        rr['return']=0

    print "ENDING"
    print  rr['return']

    #### NO ADD STUFF BELOW    
    return rr

# Do not add anything here!
