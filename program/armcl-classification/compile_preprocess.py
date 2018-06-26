#! /usr/bin/env python

#
# Copyright (c) 2018 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#

import json

def ck_preprocess(i):
  install_env = {}

  ver = i['deps']['library']['cus'].get('version_split')
  if len(ver) >= 2 and (ver[0] > 18 or (ver[0] == 18 and ver[1] >= 5)):
    install_env['CK_COMPILER_FLAGS_OBLIGATORY'] = \
      '$<<CK_COMPILER_FLAGS_OBLIGATORY>>$ -DARMCL_18_05_PLUS'
  
  return {'return': 0, 'install_env': install_env} 
