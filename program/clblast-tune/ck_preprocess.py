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

### copy linux directory 
import shutil, errno


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

def ck2clblast(old, new):
##    print (json.dumps(new, indent=2))
    temp_db = new['db']
    temp_statistics = new['statistics']
    del new['db']
    del new['statistics']
    ### now new has the head 
    # From DB I copy the exact kernel name and kernel family. USE THE FIRST ELEM IN DB... 
    new['kernel'] = temp_db[0]['kernel']
    new['kernel_family'] = temp_db[0]['kernel_family']
  
    ####### EXTRACT BEST CONFIGURATION FROM STATISTICS
#    print (json.dumps(temp_statistics, indent=2)) 
    myparams = temp_statistics['best_configuration']['parameters']
    #### TO FIX PRECISION IS IN PARAMETES
    new['precision']= str(myparams['PRECISION'])
    del myparams['PRECISION']
 
    print myparams
    ### NOW SEACH IN OLD
    exist = 0 # if does not exist just add a new element in list 
    new['results'] = [{'parameters': myparams, 'time': 0.1}]
    for best_entry in old:
        if ((best_entry['kernel_family'] == new['kernel_family'])   and \
           (best_entry['kernel'] == new['kernel'])   and \
           (best_entry['precision'] == new['precision'])    and \
           (best_entry['device_vendor'] == new['device_vendor'])   and \
           (best_entry['device_type']== new['device_type']) and \
           ((best_entry['device'] == new['device'])) ):
#            print best_entry
#            print best_entry['results'], len(best_entry['results'])
            exist = 1
            print "[CK2CLBLAST] Replace a entry for ", new['device'], best_entry['device']
            best_entry['results'] = new['results']
    if not exist:
        print "[CK2CLBLAST] Add new entry for ", new['device']
        old.append(new)
    
    ## RETURN 0 to avoid CK RECOMP 
    return 1

def copy(src, dst):
    for filename in glob.glob(os.path.join(src, '*.hpp')):
        shutil.copy(filename, dst)

def make(src, dest, tos, tdid, myuoa):
    #### API CK FOR COMPILATION
    #### MODIFY A RUN TIME SET PACKAGE_GIT
    #### Compile again
    r=ck.access({'action':'search','module_uoa':'env','tags':'clblast-tune', 'target_os':tos, 'device_id':tdid})
    if r['return']>0: return r
    lst=r['lst']
    ie = 0
    if len(lst)==0 or len(lst)>1:
       for le in lst:
           if le['data_uid'] == myuoa:
              break
           ie=ie+1
    muid=lst[ie]['module_uid']
    duid=lst[ie]['data_uid']
    r=ck.access({'action':'load','module_uoa':muid,'data_uoa':duid})
    if r['return']>0: return r
#DIFFERNCES: PACKAGE_GIT NO, PACKAGE_PATCH": "NO"
    odeps=r['dict']['deps']
    envd = {"CMAKE_CONFIG": "Release",
            "PACKAGE_AUTOGEN": "NO",
            "PACKAGE_BUILD_TYPE": "cmake",
	    "PACKAGE_CONFIGURE_FLAGS": "",
	    "PACKAGE_CONFIGURE_FLAGS_ANDROID": "-DBUILD_SHARED_LIBS=OFF",
	    "PACKAGE_CONFIGURE_FLAGS_LINUX": "",
	    "PACKAGE_CONFIGURE_FLAGS_WINDOWS": "",
	    "PACKAGE_GIT": "NO",
	    "PACKAGE_GIT_CHECKOUT": "development",
	    "PACKAGE_PATCH": "NO",
	    "PACKAGE_SKIP_CLEAN_INSTALL": "NO",
	    "PACKAGE_SKIP_CLEAN_OBJ": "YES",
	    "PACKAGE_SKIP_CLEAN_PACKAGE": "NO",
	    "PACKAGE_SKIP_CLEAN_SRC_DIR": "YES",
	    "PACKAGE_SKIP_CMAKE_TARGET": "NO",
	    "PACKAGE_SUB_DIR": "src",
	    "PACKAGE_SUB_DIR1": "src",
	    "PACKAGE_URL": "https://github.com/CNugteren/CLBlast"
    }
    ii={'action':'install',
       'module_uoa':'package',
       'data_uoa':'lib-clblast-master-universal-tune',
       'target_os':tos,
       'device_id':tdid,
       'deps':odeps,
       'env':envd,
       'out':'con',
       'quiet':'yes'
    }
    print "[Make CLBLAST] copy kernels header from "+src +"to "+dest
    copy(src, dest) 
    print "[Make CLBLAST] compile CLBLAST-tune"
    r=ck.access(ii)   
    return r


def ck_preprocess(i):
    ck=i['ck_kernel']
    del i['ck_kernel']
    rt=i['run_time']
    deps=i['deps']
    env=i.get('env',{})
    pass_to_make = i
    pli = i['misc']
    rr={}
  
    #print (json.dumps(deps['lib-clblast'], indent=2)) 
    #print deps['lib-clblast']['uoa']
    # Load both stderr and stdout. Concatenate into one list.
    # NB: This assumes that Caffe iterates only once (--iterations=1).
    # Otherwise, looping over the log would be required.

#    for target in VENDOR_TRANSLATION_TABLE:
#            if d["device_vendor"] == target:
#               d["device_vendor"] = VENDOR_TRANSLATION_TABLE[target]

    tos = pli['target_os_uoa']
    tdid = pli['device_id']
    adf=pli['add_to_features']
    #compiler=adf['gpgpu'][0]['gpgpu_deps']['compiler']['uoa']
    #print (json.dumps(i['env'], indent=2))
    if env['CK_FORCE_RECOMPILE'] == "0":
           rr["return"] = 0
           return rr
    #print tos, tdid)
    print "[CK_FORCE_RECOMPILE] ",env['CK_FORCE_RECOMPILE']
    #GET DEFAULT VALUE from CLBlast
    deps_cb= deps['lib-clblast']
    uoa= deps_cb['uoa']
    b=deps_cb['cus']
    pl = b['path_lib']
    #bench="xgemm"
    #bench +=".hpp"
    pl=pl.split("install")[0] #### VERIFY WITH INSTALL SCRIPT 
    pl_suff= "src/scripts/database/"
    pk=pl
    pk_suff="src/src/database/kernels/"
    pl += pl_suff
    pk += pk_suff
#    print pl, pk
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
    best = database_best_results['sections']
    print "[Tuning] Checking new best configuration"
    ### loadfile To generilize
    mybestf=env['CK_CLBLAST_BEST_CONF_FILE']
    mybestd={}
    if os.path.isfile(mybestf):
        mybestd = json.loads(open(mybestf).read())
        del mybestd['data']
        #####
        MYFIND = ck2clblast(best, mybestd) 
    else:
       MYFIND = 0 
    if MYFIND:
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
        rr = make(src_new_kernels, pk, tos , tdid, uoa)
        
    else:
        print "[Tuning] Nothing to do"
        print "[Tuning] Exit"
        rr['return']=0


    #### NO ADD STUFF BELOW    
    return rr

# Do not add anything here!
