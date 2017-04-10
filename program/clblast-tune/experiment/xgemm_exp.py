import ck.kernel as ck
import copy
import re 



#######################################
#    Description
#    
#    
#    KERNEL = Xgemm
#    INPUT = M,N,K SIZE. PRECISION
#    OUTPUT = CONFIGURATION
#######################################

'''
Set interval or Resolution 25%
Set resolution 0 //powersafe mode take min
Set resolution 1// performance mode take max
Set resolution x[0 and 1] 
           Convert x in percent
Start from lower Freq. The next freq is the first freq with freq_min + x % of power. 
Set resolution 2 
            Try all frequencies 

Example of Set resolution x 
Freq availables 100 MHz, 200MHz, 400MHz, 800Mhz, 2000Mhz
Set interval 50%.
Lvl 0: 100Mhz
Lvl 1: 150Mhz // value not allowed
Lvl 2: 200Mhz OK
Lvl 3: 250Mhz 
'''

# clock_resolution
# 0 min freq 
# 1 max freq [default]
# (0,1) called resolution convert. Create intervals starting from min. Interval 0 = frequencies between min and min+(min*resolution)
#otherwise takes min and mix and divide per a fixed number 
# 2 run all the frequencies
clock_resolution = 1.0
kernel = ['xgemm_direct-fp32']
title =  "My Experiment"
# size of the matrix m,n,k
size_m = ["512", "256", "128", "1024" ]
size_n = ["256", "512", "128", "1024" ]
size_k = ["128","256",  "1024","128" ]

precision=32 # default 
run = 1 # default 

VERBOSE=0
VERBOSE_STR="[VERBOSE] "
DEBUG = 0
DEBUG_STR="[DEBUG] "


def do(i):
    if VERBOSE or DEBUG:
	    print '[Experiment] ', title
	    print '[Preparing pipeline] Clock resolution: ', clock_resolution
	    print '[Preparing pipeline] Matrix sizes (m,n,k): ', size_m, size_n, size_k
	    print '[Preparing pipeline] Precision: ', precision
	    print '[Preparing pipeline] Run for configuration: ', run
	    print '[Preparing pipeline] More parms... '
    # Detect basic platform info. 
    ii={'action':'detect',
        'module_uoa':'platform',
        'out':'out'}
    r=ck.access(ii)
    if DEBUG: print DEBUG_STR, r
    if r['return']>0: return r

    # Host and target OS params.
    hos=r['host_os_uoa']
    hosd=r['host_os_dict']
    tos=r['os_uoa']
    tosd=r['os_dict']
    tdid=r['device_id']

    if DEBUG: print DEBUG_STR, hos, hosd
    if DEBUG: print DEBUG_STR, tos, tosd, tdid

    # Load CLBLAST program meta and desc to check deps.
    ii={'action':'load',
        'module_uoa':'program',
        'data_uoa':'clblast-tune'}
    rx=ck.access(ii)
    if DEBUG: print DEBUG_STR, rx
    if rx['return']>0: return rx
    meta= rx['dict']
    if VERBOSE: print VERBOSE_STR, meta

    # Get compile-time and run-time deps.
    cdeps=meta.get('compile_deps',{})
    rdeps=meta.get('run_deps',{})

    # Merge rdeps with cdeps for setting up the pipeline (which uses
    # common deps), but tag them as "for_run_time".
    for k in rdeps:
        cdeps[k]=rdeps[k]
        cdeps[k]['for_run_time']='yes'
    # CLblast libs.
    depl=copy.deepcopy(cdeps['lib-clblast'])
    if VERBOSE: print VERBOSE_STR, depl
    #ON LOCAL MACHINE 
    ii={'action':'resolve',
    'module_uoa':'env',
    'host_os':hos,
    'target_os':tos,
    'device_id':tdid,
    'deps':{'lib-clblast':copy.deepcopy(depl)}
    }
    r=ck.access(ii) 
    if DEBUG: print DEBUG_STR, r
    if r['return']>0: return r
    udepl=r['deps']['lib-clblast'].get('choices',[]) 
    if len(udepl)==0: return {'return':1, 'error':'no installed CLBlast libs'}

    #prepare pipeline
    '''
    ii={'action':'pipeline',
        'module_uoa':'program',
        'data_uoa':'clblast-tune',
        'prepare':'yes',
        'dependencies': cdeps,
        'no_compiler_description':'yes',
        'cmd_key':kernel[0], 
        'cpu_freq':'max',
        'gpu_freq':'max',
        'flags':'-O3', 
    }
    '''
    ii={'action':'pipeline',
        'module_uoa':'program',
        'data_uoa':'clblast-tune',
        'prepare':'yes',
        'dependencies': cdeps,
        'no_compiler_description':'yes',
        'cmd_key':kernel[0], 
        'flags':'-O3', 
    }
    r=ck.access(ii)
    if DEBUG: print DEBUG_STR, r
    if r['return']>0: return r
    fail=r.get('fail','')
    if fail=='yes': return {'return':10, 'error':'pipeline failed ('+r.get('fail_reason','')+')'}

    ready=r.get('ready','')
    if ready!='yes': return {'return':11, 'error':'pipeline not ready'}

    state=r['state']
    tmp_dir=state['tmp_dir']
    xcdeps=r.get('dependencies',{})
    # Clean pipeline.
    if 'ready' in r: del(r['ready'])
    if 'fail' in r: del(r['fail'])
    if 'return' in r: del(r['return'])
    pipeline=copy.deepcopy(r)


    record_repo='local'
    record_uoa='explore-matrix-size-'+kernel[0]
    ck.out('---------------------------------------------------------------------------------------')
    ck.out('Experiment - %s:%s' % (record_repo, record_uoa))

    cpipeline=copy.deepcopy(pipeline)
    ii={
        'action':'autotune',
        'module_uoa':'pipeline',
        'data_uoa':'program',
        'choices_order':[
            [
	     '##env#CK_CLBLAST_MSIZE'
	    ],
	    [
	     '##env#CK_CLBLAST_NSIZE',
	    ],
	    [
	     '##env#CK_CLBLAST_KSIZE'
	    ]
        ],
        'choices_selection':[
            {"type":"loop-with-next", "choice":size_m, "default":"256"},
            {"type":"loop-with-next", "choice":size_n, "default":"256"},
            {"type":"loop-with-next", "choice":size_k, "default":"256"}

        ],
        'features_keys_to_process':['##choices#*'],
 

        'iterations':-1,
        'repetitions':1, 
        'record':'yes',
        'record_failed':'yes',
        'record_params':{
            'search_point_by_features':'yes'
        },
        'record_repo':record_repo,
        'record_uoa':record_uoa,
        'tags':['explore-clblast-matrix-size', kernel[0]],
        'pipeline': cpipeline,
        'out':'no'  

    }
    r=ck.access(ii)
    if DEBUG > 0: print DEBUG_STR, r
    if r['return']>0: return r
    fail=r.get('fail','')
    if fail=='yes':
       return {'return':10, 'error':'pipeline failed ('+r.get('fail_reason','')+')'}

    return  {'return':0}



r=do({})
if r['return']>0: ck.err(r)
