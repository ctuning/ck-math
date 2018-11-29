#! /usr/bin/env python
#
# Copyright (c) 2018 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#

import os
import re

def ck_preprocess(i):
  install_env = {}

  ck = i['ck_kernel']

  ck.out('')
  ck.out('Preprocess compilation for ArmCL')

  ver = i['deps']['library']['cus'].get('version_split')
  ver_major = ver[0] if len(ver) > 0 else 0
  ver_minor = ver[1] if len(ver) > 1 else 0
  if ver_major == 0 and ver_minor == 0:
    # ck package version can be set to something like `master`
    # But we can read true ArmCL version from its SConscript,
    # supposing it has the format `VERSION = "v18.05"`
    lib_env = i['deps']['library']['dict']['env']
    lib_src_dir = lib_env.get('CK_ENV_LIB_ARMCL_SRC')
    SConscript = os.path.join(lib_src_dir, 'SConscript')
    if not os.path.isfile(SConscript):
      ck.out('SConscript file is not found\n{}'.format(SConscript))
    else:
      regex = r"^\s*VERSION\s*=\s*\"v(?P<major>\d+).(?P<minor>\d+)"
      with open(SConscript) as f:
        for line in f:
          match = re.match(regex, line)
          if match:
            ver_major = int(match.group('major'))
            ver_minor = int(match.group('minor'))
            break

  if ver_major == 0 and ver_minor == 0:
    ck.out('ArmCL version is not set or incomplete')
    return {'return': 0}

  ck.out('ArmCL version: {}.{}'.format(ver_major, ver_minor))

  if ver_major >= 18:
    ver_defs = ''
    if ver_minor >= 11:
      ver_defs += ' -DARMCL_18_11_PLUS'
    if ver_minor >= 8:
      ver_defs += ' -DARMCL_18_08_PLUS'
    if ver_minor >= 5:
      ver_defs += ' -DARMCL_18_05_PLUS'
    if ver_defs:
      install_env['CK_COMPILER_FLAGS_OBLIGATORY'] = \
        '$<<CK_COMPILER_FLAGS_OBLIGATORY>>$ ' + ver_defs

  ck.out('')
  return {'return': 0, 'install_env': install_env}
