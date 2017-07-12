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
def ck_postprocess(i):
    ck=i['ck_kernel']
    rt=i['run_time']
    deps=i['deps']

    d={}

    env=i.get('env',{})

    # Load both stderr and stdout. Concatenate into one list.
    # NB: This assumes that Caffe iterates only once (--iterations=1).
    # Otherwise, looping over the log would be required.

#    For debugging
#    rt['run_cmd_out1']='stdout.log'
#    rt['run_cmd_out2']='stderr.log'
#    rt['run_output_files']=["clblast_xgemm_1_32.json","clblast_xgemm_2_32.json"]

    rf1=rt['run_cmd_out1']
    rf2=rt['run_cmd_out2']
    rf3=rt['run_output_files'][0]
    if len(rt['run_output_files']) > 1:
        rf4=rt['run_output_files'][1]
    else:
        rf4="None"
    print("[postprocessing] Loading json output %s " % (rf3 ))
    print("[postprocessing] Loading json output %s " % (rf4 ))
    lst=[]
    r={}
    if os.path.isfile(rf1):
       r=ck.load_text_file({'text_file':rf1,'split_to_list':'yes'})
       if r['return']>0: 
           r['error']="Error loading rf1 file"
           return r
       lst+=r['lst']
    if os.path.isfile(rf2):
       r=ck.load_text_file({'text_file':rf2,'split_to_list':'yes'})
       if r['return']>0:
           r['error']="Error loading rf2 file"
           return r
       lst+=r['lst']
    c1 = os.path.isfile(rf3)
    c2 = os.path.isfile(rf4)
    if c1:
        rj1 = json.loads(open(rf3).read())

    if c2:
        rj2= json.loads(open(rf4).read())

    if ((c1 == 0) and (c2 == 0)):
        r['return'] = 0
        print("[postprocessing] Unable to read json output")
        r['return'] = 1;
        r['error'] = 'Unable to read json output' 
        return r;
    if ((c1)== 0):
        rj1 = rj2
    #### CREATE UNIQUE OUTPUT
    print("[postprocessing] Creating dictionary")
    d['post_processed']='yes'
#    mydict['device_core_clock'] = 'value from script'
#   SET ARCH INFORMATION
    d['device_vendor'] = rj1['device_vendor']
    d['device_type'] = rj1['device_type']
    d['device'] = rj1['device']
    d['device_compute_units'] = rj1['device_compute_units']
    # Notice that often is not really accurated; TBC 
    d['device_core_clock'] = rj1['device_core_clock']

    #Experiment Information
    kern_family_len = len(rj1['kernel_family'].split('_'))
    kernel_family=rj1['kernel_family'].split("_")[0]
    if kern_family_len > 1:
        if rj1['kernel_family'].split("_")[1] == "direct":
            #concut again special case the kernal family of Xgemm_directNN is the same of other xgemm_direct
             kernel_family = kernel_family + "_" + "direct"
    d['kernel'] = kernel_family
    if 'arg_beta' in d:
        d['arg_beta'] = rj1['arg_beta']
    if 'arg_m' in d:
        d['arg_m'] = rj1['arg_m']
    if 'arg_n' in d:
        d['arg_n'] = rj1['arg_n']
    if 'arg_k' in d:
        d['arg_k'] = rj1['arg_k']
    if 'arg_alpha' in d:
        d['arg_alpha'] = rj1['arg_alpha']
    d['precision'] = rj1['precision']

    for target in VENDOR_TRANSLATION_TABLE:
            if d["device_vendor"] == target:
                d["device_vendor"] = VENDOR_TRANSLATION_TABLE[target]


    #### Add results per strategy
#    print "ADD RESULTs"
    l=[]
    if ( c1 ):
        tmp = {'strategy':'exhaustive', 'result': rj1['results']}
        l.append(tmp)
    if ( c2 ):
        tmp = {'strategy':'random', 'result': rj2['results']}
        l.append(tmp)

    d['data'] = l

    #GET DEFAULT VALUE from CLBlast
    deps_cb= deps['lib-clblast']
    b=deps_cb['cus']
    pl = b['path_lib']
    bench=d['kernel']
    bench +=".hpp"
    pl=pl.split("install")[0] #### VERIFY WITH INSTALL SCRIPT 
    pl_suff= "src"+os.sep+"scripts"+os.sep+"database"+os.sep
    pl += pl_suff
    pl1 = pl+"database"+os.sep

    sys.path.append(pl)
    sys.path.append(pl1)
    ####
    import database.io as io
    import database.db as db
    import database.clblast as clblast
    import database.bests as bests
    import database.defaults as defaults
    database_filename=pl+"database.json"

    if os.path.isfile(database_filename) and os.path.getsize(database_filename)==0:
       os.remove(database_filename)

    if not os.path.isfile(database_filename):
       io.download_database(database_filename, DATABASE_SERVER_URL)
    else:
       print("[database] DB found")
    if os.path.isfile(database_filename):
       database = io.load_database(database_filename)


    # Retrieves the best performing results
    print("[database] Calculating the best results per device/kernel...")
    database_best_results = bests.get_best_results(database)
    search_vendor=d['device_vendor']
    search_device= d['device'] 
    search_device_type=d['device_type']
    search_kernel=d['kernel']
    search_precision= d['precision']
    # Determines the defaults for other vendors and per vendor
    print("[database] Calculating the default values...")
    database_defaults = defaults.calculate_defaults(database, 0) #second args denotes VERBOSE or NOT
    database_best_results["sections"].extend(database_defaults["sections"])
    database_best_filename='database_best.json'
    # Optionally outputs the database to disk
    if VERBOSE:
        io.save_database(database_best_results, database_best_filename)
        #print("[database] Producing a C++ database in current dir...")
        #clblast.print_cpp_database(database_best_results, ".")
    #### TEST to get best and default param 
    best = database_best_results['sections']
    ll = []
    count = 0
    index = -1
    for best_entries in best:
       #print best_entries['kernel_family'] + " " + search_kernel
       if( (best_entries['kernel_family'] == search_kernel)   and \
           (best_entries['device_vendor'] == search_vendor)   and \
           (best_entries['precision'] == search_precision)    and \
           (best_entries['device_type']== search_device_type) and \
           ((best_entries['device'] == search_device) or (best_entries['device']=='default')) ):
            if VERBOSE: print("[postprocess] Best entry %s found" % (best_entries))
            tmp=best_entries            
            ll.append(tmp)
    ##### Find Timing in d[data]
    stat=[]
    for s in d['data']:
  #      print s.get('strategy', {})
        result=s.get('result',{})
        for rrr in result:
            compare = rrr['parameters']
            for il in ll:
                    best =  il.get('results',{})[0].get('parameters',{})
                    dev= il['device']
                    ### comparing value by value
                    isBest= True
                    for bb in best.keys():
                    #    print bb, best[bb], compare[bb]
                         if (best[bb] != compare[bb]):
                            isBest = False
                            break
                    if (isBest):
                        rrr['device'] = dev
                        stat.append(rrr)
    index=0
    bindex=-1
    bres={} 
    min_time=sys.float_info.max
    for s in d['data']:
  #      print s.get('strategy', {})
        result=s.get('result',{})
        for i in result:
            index +=1
            if (i['time'] < min_time):
                min_time=i['time']
                bres=i
                bindex=index

#    print "Best performance: ", min_time,bres 
    l_m = 0
    l_n = 0
    l_k = 0
    if 'arg_m' in d:
        l_m = float(d["arg_m"])
    if 'arg_n' in d:
        l_n = float(d["arg_n"])
    if 'arg_k' in d:
        l_k = float(d["arg_k"])
    m = l_m
    n = l_n
    k = l_k
    if bres.get('time','')!='':
       gflops = 2.0*m*n*k
       time = float(bres["time"])/1000.0
       gflops = gflops/time/1000.0/1000.0/1000.0
       bres['GFLOPS'] =gflops


    bestdefstat={}
    defstat = {}
    for i in stat:
        time=float(i["time"])/1000.0
        gflops = 2.0*m*n*k
        gflops = gflops/time/1000.0/1000.0/1000.0
        i['GFLOPS'] =gflops
        if i['device'] == 'default':
            defstat=i
        else:
            bestdefstat=i

    d["statistics"] = {'best_configuration': bres, 'default_configuration': defstat, 'default_family':bestdefstat}
    if VERBOSE:
        print ("[postprocessing] %s" %(d["statistics"]))
    if len(ll) > 0:
        if VERBOSE: 
            print (len(ll))
        d['db'] = ll
    else:
        d['db'] = 'na'
    rr={}
    rr['return']=0
#    output_filename='tmp-ck-clblast-tune-'+d['kernel']+'-'+d['arg_m']+'-'+d['arg_n']+'-'+d['arg_k']+'-'+d['precision'] +'.json' 
    output_filename='tmp-ck-clblast-tune.json'
##    print output_filename
    if d.get('post_processed','')=='yes':
        rr=ck.save_json_to_file({'json_file':output_filename, 'dict':d})
        if rr['return']>0: return rr
    else:
        rr['return']=1
        rr['error']='FAIL'
    print("[postprocessing] Exit code %s" %(rr['return']))
    
    return rr

# Do not add anything here!
