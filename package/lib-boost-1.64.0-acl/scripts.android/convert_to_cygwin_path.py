#
# Collective Knowledge (os)
#
# See CK LICENSE.txt for licensing details
# See CK COPYRIGHT.txt for copyright details
#
# Developer: Grigori Fursin, Grigori.Fursin@cTuning.org, http://fursin.net
#

import os
import sys

if len(sys.argv)>1:
    p=sys.argv[1]

    pp=p.replace('\\','/')

    print (pp)

exit(0)
