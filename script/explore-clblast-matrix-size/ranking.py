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
#print('CK version: %s' % ck.__version__)

# Find Json files in a specific directory... 

def find_json(p):
    jfiles=[]
    for f in os.listdir(p):
    ### return list of json of interest
        if f.endswith(".0001.json"):
            jfiles.append(p+f)
    return jfiles


def get_data(f):
    exp = json.loads(open(f).read()) 
#    exp = json.load(open(f).read())
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

def get_data_header(f):
    exp = json.loads(open(f).read())
    name =exp['characteristics_list'][0]
    header= name.get('run')
    return header


def find_it(p, o):
   res = {"parameters": p}
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


def getKey(item):
    val =  float(item.get('total_time'))
    print val
    return val
def find_best(dlist, w):
    #### for each ranking aggragate the best according 
    configurations = dlist[0] 
    best = sys.float_info.max
    configuration_best_index =  len(configurations)
    configuration_count = 0
    final_score = []
    for  configuration in configurations:
        res = find_it(configuration['parameters'],dlist)
        tmp_time = 0
        wcounter = 0
        for ctime in res["time"]:
              tmp_time +=ctime*w[wcounter]
        if tmp_time < best:
           best= tmp_time
           configuration_best_index = configuration_count
        res["total_time"] = tmp_time
        final_score.append(res)
        configuration_count +=1
    mbest = final_score[configuration_best_index]
    print (json.dumps(mbest, indent=2))
#    print ("ALL RANKING")
#    sorted(final_score, key=operator.itemgetter('total_time'))
#    sorted(final_score, key=getKey)
#    print (json.dumps(final_score, indent=2))
    return mbest


################################
def main(arg):
    # CUSTOMIZABLE VARIABLES!!!!
    module_uoa = 'experiment'
    repo_uoa = 'explore-matrix-size-xgemm-fp32-firefly-rk3399'
    tags='explore-clblast-matrix-size'
    output_filename = 'tmp-ck-clblast-tune.json'
    
    weights_filename='NULL'
    
    WEIGHTS = 0 
    if arg.fp is not None:
        weights_filename = arg.fp
        if (os.path.isfile(weights_filename)):
            print("{RANKING ERROR %s not found. USE WEIGHTS=0}" %(weights_filename))
            WEIGHTS = 1 
        else:
             print("[RANKING ERROR] %s not found. USE WEIGHTS=0" %(weights_filename))

   
    ### END CUST
    
    
    dlist=[]
    dblist=[]
    r=ck.access({'action':'search', 'repo_uoa':repo_uoa, 'module_uoa':module_uoa, 'tags':tags})
    if r['return']>0:
        print ("Error: %s" % r['error'])
    experiments=r['lst']
    if len(experiments) == 0:
        print("No experiments found in repo %s with tags %s" %(repo_uoa, tags))
        exit(1)

    for exp in experiments:
#        print exp
        data_uoa = exp['data_uoa']
        r = ck.access({'action':'list_points', 'repo_uoa':repo_uoa, 'module_uoa':module_uoa, 'data_uoa':data_uoa})
        if r['return']>0:
            print ("Error: %s" % r['error'])
            exit(1)
    tags = r['dict']['tags']
#    print tags
    npoint = len(r['points'])
    print ("[RANKING] Number of matrices: %s" %(npoint))
        #    print npoint
    for point in r['points']:
        point_file = os.path.join(r['path'], 'ckp-%s.0001.json' % point)
        d = get_data(point_file) 
        dlist.append(d)

    # LOAD WEIGHTS
    
    w = []
#    WEIGHTS = os.path.isfile(weights_filename) and WEIGHTS
    if (WEIGHTS == 0):
        for i in range(0,npoint):
            w.append(1)
    else: 
        print("Loading weights %s" %(weights_filename))
        wdict = json.loads(open(weights_filename).read())
        for i in wdict:
            print i.get('Execution time (%)')
            w.append(float(i.get('Execution time (%)')))

    output = get_data_header(point_file)
    # FIND THE BEST
    #configurations = dlist[0]
    #best = sys.float_info.max
    #configuration_best_index =  len(configurations)
    #configuration_count = 0
    #final_score = []
    #for  configuration in configurations:
    #    res = find_it(configuration['parameters'],dlist)
    #    tmp_time = 0
    #    for ctime in res["time"]:
    #          tmp_time +=ctime
    #    if tmp_time < best:
    #       best= tmp_time
    #       configuration_best_index = configuration_count
    #    res["total_time"] = tmp_time
    #    final_score.append(res)
    #    configuration_count +=1
    #mbest = final_score[configuration_best_index]
    mbest= find_best(dlist, w)
    
    ### PREPARE OUTPUT
    del mbest['time']
    del mbest['total_time']
    mbest['GFLOPS'] = 0.0
    mbest['kernel'] = output.get('kernel')
    output['data'] = 'na'
    output['db'] = 'na'
    output['statistics'] = {'default_family':{}, 'default_configuration':{}, 'best_configuration': mbest }
    #print (json.dumps(output, indent=2))
    rr=ck.save_json_to_file({'json_file':output_filename, 'dict':output})

parser = argparse.ArgumentParser(description='Short sample app')
parser.add_argument("--file", action="store", dest="fp")
myarg=parser.parse_args()


main(myarg)












