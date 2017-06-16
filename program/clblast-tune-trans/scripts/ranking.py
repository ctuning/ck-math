import json
import os
import re
import sys
import operator
import sys
import os.path
import glob
import argparse



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
    
    jl = find_json(path)
    print jl
    dlist=[]
    dblist=[]
    for i in jl:
        d = get_data(i)
        print len(d)
        #ds = assign_score(d)
        dlist.append(d)



    
    d2 =  get_data_db(jl[0])
    for d2c in d2:
        dblist.append(d2c)
        
    ## get just one set of configuration
#    dl = find_best(dl)
    listconf = dlist[0]
#    print dlist
    best = sys.float_info.max
    index =  len(listconf)
    print index
    conf =0
    final_score = []
    for  i in listconf:
#        print i['parameters']
#        print conf
        res = find_it(i['parameters'],dlist)
        tmp_time = 0
        for ctime in res["time"]:
              tmp_time +=ctime
        if tmp_time < best:
           best= tmp_time
           index = conf
        res["total_time"] = tmp_time
        final_score.append(res)
        conf +=1
#        print i['time']
    for ii in dblist:
       i = ii['results']
       #print i[0]
       res = find_it(i[0]['parameters'],dlist)
       print res
    print "Best Result is: ",final_score[index]
#    sorted(final_score, key=operator.itemgetter('total_time'))    
#    print "TOP 5 Results"
#    for top in range(0, 6):
#        print final_score[top]

 #   print "Best Result (check) is: ", final_score[0]
 #   print "Worst Result (check) is: ", final_score[len(final_score)-1]

main()












