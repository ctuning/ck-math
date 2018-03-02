#
# Convert raw output of CLBlast
# to the CK timing format.
#
# Developers:
#   - Grigori Fursin, cTuning foundation, 2016
#   - Anton Lokhmotov, dividiti, 2016
#   - Michel Steuwer, University of Edinburgh, 2016
#

import json
import os
import re

def ck_postprocess(i):
    ck=i['ck_kernel']

    d={}

    env=i.get('env',{})
    rt=i['run_time']
    rf1=rt['run_cmd_out1']
    r=ck.load_text_file({'text_file':rf1,'split_to_list':'yes'})
    if r['return']>0: return r

    r['return']=1
    for line in r['lst']:
        line = re.sub(r'\s+', '',line)
        ld = line.split("=")
        if len(ld) > 1:
           d[ld[0]] = ld[1]

    d["post_processed"] = 'yes'
    d["GFLOPS"]=d['GFLOPS_MAX']
    check = 0 if 'GFLOPS' in d else 1
    r['return'] = check or d['STATUS']
    if r['return'] > 0:
      r['error'] = 'failed to find the time in ArmCL SGEMM output'

    r=ck.save_json_to_file({'json_file':'tmp-ck-acl-sgemm-client.json', 'dict':d})
    if r['return'] > 0:
      r['error'] = 'failed to find the time in ArmCL SGEMM output'

    return r

# Do not add anything here!
