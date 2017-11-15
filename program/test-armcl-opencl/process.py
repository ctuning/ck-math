#
# Copyright (c) 2017 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#
# Convert raw output of an armcl to the CK format.
#
# Developer(s):
#   - Anton Lokhmotov, dividiti, 2017
#   - Grigori Fursin, cTuning foundation, 2017
#

import json
import os
import re
import struct


def ck_preprocess(i):
    ck=i['ck_kernel']
    rt=i['run_time']

    meta=i['meta']
    env=i['env']

    return {'return':0}

def ck_postprocess(i):
    ck=i['ck_kernel']
    rt=i['run_time']
    env=i['env']
    deps=i['deps']

    # Dictionary to return.
    d={}

    # Call dvdt prof script
    fout=rt.get('run_cmd_out1','')
    if fout!='':
       r=ck.access({'action':'run', 'module_uoa':'script', 'data_uoa':'ctuning.process.dvdt-prof', 
                    'code':'dvdt_prof', 'func':'process', 
                    'dict':{'file_in':fout, 'file_out':'tmp-dvdt-prof.json', 
                            'data':d, 'env':env, 'deps':deps}})
       if r['return']>0: return r

    r=ck.save_json_to_file({'json_file':rt['fine_grain_timer_file'], 'dict':d})
    if r['return']>0: return r

    return {'return':0}

# Do not add anything here!
