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

def ck_postprocess(i):
    ck=i['ck_kernel']
    rt=i['run_time']
    deps=i['deps']

    d={}

    env=i.get('env',{})

    # Load both stderr and stdout. Concatenate into one list.
    # NB: This assumes that Caffe iterates only once (--iterations=1).
    # Otherwise, looping over the log would be required.
    rf1=rt['run_cmd_out1']
    rf2=rt['run_cmd_out2']
    rf3=rt['run_output_files'][0]
    rf4=rt['run_output_files'][1]

#    print rf3,rf4
    lst=[]
    r={}
    if os.path.isfile(rf1):
       r=ck.load_text_file({'text_file':rf1,'split_to_list':'yes'})
       if r['return']>0: return r
       lst+=r['lst']
    if os.path.isfile(rf2):
       r=ck.load_text_file({'text_file':rf2,'split_to_list':'yes'})
       if r['return']>0: return r
       lst+=r['lst']
    c1 = os.path.isfile(rf3)
    c2 = os.path.isfile(rf4)
    if c1:
	rj1 = json.loads(open(rf3).read())
        rj1['strategy']='exhaustive'
        print rj1

    if c2:
        rj2= json.loads(open(rf3).read())
        rj2['strategy']='random'

    if ((c1 == 0) and (c2 == 0)):
        r['return'] = 0
        return r

    mydict=rj1;
    mydict['post_processed']='yes'
#    mydict['device_core_clock'] = 'value from script'


    #GREP DEFEAULT VALUE from CLBlast
    deps_cb= deps['lib-clblast']
    b=deps_cb['cus']
    pl = b['path_lib']
    bench="xgemm"
    bench +=".hpp"
    pl=pl.split("install")[0]
   
    pl_suff= "src/src/database/kernels/" + bench 
    pl+=pl_suff
    if os.path.isfile(pl):
       print "Try to parse " + pl



    rr={}
    rr['return']=0
    if mydict.get('post_processed','')=='yes':
        r=ck.save_json_to_file({'json_file':'tmp-ck-clblast-tune.json', 'dict':mydict})
        if r['return']>0: return r
    else:
        rr['return']=1
        rr['error']='FAIL'
        print(mydict)
    return rr

# Do not add anything here!
