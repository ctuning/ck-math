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



def make(a, src, dest):
    myk = a['deps']
    print "[Make CLBLAST] copy kernels header from "+src +"to "+dest

    #### API CK FOR COMPILATION
    #### MODIFY A RUN TIME SET PACKAGE_GIT

    #### Compile again
   
    return 1





def ck_preprocess(i):
    ck=i['ck_kernel']
    rt=i['run_time']
    deps=i['deps']
    env=i.get('env',{})
    pass_to_make = i
    # Load both stderr and stdout. Concatenate into one list.
    # NB: This assumes that Caffe iterates only once (--iterations=1).
    # Otherwise, looping over the log would be required.

#    for target in VENDOR_TRANSLATION_TABLE:
#            if d["device_vendor"] == target:
#               d["device_vendor"] = VENDOR_TRANSLATION_TABLE[target]


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
    FIND = 0 
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

        rr['return'] = make(pass_to_make,src_new_kernels, pk)
        
    else:
        print "[Tuning] Nothing to do"
        print "[Tuning] Exit"
        rr['return']=0

   


    #### NO ADD STUFF BELOW    

    return rr

# Do not add anything here!
