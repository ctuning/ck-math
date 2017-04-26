import json
import os
import re
import sys
import operator
import sys
import os.path
import glob
import argparse

import ck.kernel as ck
print('CK version: %s' % ck.__version__)

# Find Json files in a specific directory... 

def find_json(p):
    jfiles=[]
    for f in os.listdir(p):
    ### return list of json of interest
        if f.endswith(".0001.json"):
            jfiles.append(p+f)
    return jfiles


def get_data(f):
#    exp = json.loads(open(f).read()) 
    exp = json.load(f)
    name =exp['characteristics_list'][0]
    name= name['run']
    ne = name['arg_m'] +'-' + name['arg_n'] +'-' + name['arg_k']
    s= {'name': ne}
    res = name['data'][0]
    res = res['result']
    sres =  sorted(res, key=operator.itemgetter('time'))
    return sres

def get_data_db(f):
    exp = json.loads(open(f).read()) 
    name =exp['characteristics_list'][0]
    name= name['run']
    ne = name['arg_m'] +'-' + name['arg_n'] +'-' + name['arg_k']
    s= {'name': ne}
    res = name['db']
    return res


def find_it(p, o):
   res = {"name": p}
   time = []
   for exp in o:
       op = exp 
       check = False
       for j in op:
          opp = j['parameters']
          check = False
          for i in p.keys():
             if p[i] == opp[i]:
                 check = True
             else:
                 check = False
                 break
          if check:
 #             print "Found ", p, "equal to", j["time"]
              time.append(j["time"])
              break
          else: 
#              time.append("na")
               c  = 1;
  #            print 'Not Found'
   res["time"]= time
   return res 

def find_best(dlist):
    #### for each ranking aggragate the best according 
    return dlist

def old_new():
    #### return the difference between the best result and the default one....
    return result

################################
def main():
    
    path='/home/flavio/CK_REPOS/local/experiment/explore-matrix-size-xgemm_direct-fp32/' 
    
#    jl = find_json(path)
#    print jl
    dlist=[]
    dblist=[]
#new stuff here 
    module_uoa = 'experiment'
    repo_uoa = 'local'
    tags='explore-clblast-matrix-size'
    r=ck.access({'action':'search', 'repo_uoa':repo_uoa, 'module_uoa':module_uoa, 'tags':tags})
    if r['return']>0:
        print ("Error: %s" % r['error'])
    print '\n',r
    experiments=r['lst']
    print '\n', experiments
    print 'experiments' 
    for exp in experiments:
        print exp
        data_uoa = exp['data_uoa']
        r = ck.access({'action':'list_points', 'repo_oua':repo_uoa, 'module_uoa':module_uoa, 'data_uoa':data_uoa})
        if r['return']>0:
            print ("Error: %s" % r['error'])
            exit(1)
        print r
    
    tags = r['dict']['tags']
    print tags
    for point in r['points']:
        with open(os.path.join(r['path'], 'ckp-%s.0001.json' % point)) as point_file:
            pdr = json.load(point_file)
            print (json.dumps(pdr, indent=2))
    #        d = get_data(point_file) 
    #        dlist.append(d)
            break
    exit(1)
     #print point_data_raw

#    print (json.dumps(d, indent=2))

    configurations = dlist[0]
#    print dlist
    best = sys.float_info.max
    configuration_best_index =  len(configurations)
    configuration_count = 0
    final_score = []
    for  configuration in configurations:
#        print i['parameters']
#        print conf
        res = find_it(configuration['parameters'],dlist)
        tmp_time = 0
        for ctime in res["time"]:
              tmp_time +=ctime
        if tmp_time < best:
           best= tmp_time
           configuration_best_index = configuration_count
        res["total_time"] = tmp_time
        final_score.append(res)
        configuration_count +=1
    print "Best Result is: ",final_score[configuration_best_index]










main()












