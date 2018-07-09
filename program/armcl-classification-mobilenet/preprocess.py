#
# Copyright (c) 2018 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#

import os

def ck_preprocess(i):
  def dep_env(dep, var): return i['deps'][dep]['dict']['env'].get(var)

  LABELS_FILE = 'labels.txt'
  WEIGHTS_DIR = dep_env('weights', 'CK_ENV_MOBILENET')
  LIB_DIR = dep_env('library', 'CK_ENV_LIB_ARMCL')
  LIB_NAME = dep_env('library', 'CK_ENV_LIB_ARMCL_DYNAMIC_CORE_NAME')

  new_env = {}
  files_to_push = []
  push_weights_to_remote = True
  push_libs_to_remote = True

  if i['target_os_dict'].get('remote','') == 'yes':
    # For Android weights and labels will be located near the executable
    new_env['CK_ENV_WEIGHTS_DIR'] = '.'
    new_env['CK_ENV_LABELS_FILE'] = LABELS_FILE

    # Set list of additional files to be copied to Android device.
    # We have to set these files via env variables with full paths 
    # in order to they will be copied into remote program dir without sub-paths.
    if push_libs_to_remote:
      new_env['CK_ENV_LABELS_FILE_PATH'] = os.path.join(os.getcwd(), '..', LABELS_FILE)
      new_env['CK_ENV_ARMCL_CORE_LIB_PATH'] = os.path.join(LIB_DIR, 'lib', LIB_NAME)
      files_to_push.append("$<<CK_ENV_LABELS_FILE_PATH>>$")
      files_to_push.append("$<<CK_ENV_ARMCL_CORE_LIB_PATH>>$")
      files_to_push.append("$<<CK_ENV_LIB_STDCPP_DYNAMIC>>$")

    if push_weights_to_remote:
      file_index = 0
      for file_name in os.listdir(WEIGHTS_DIR):
        if file_name.endswith('.npy'):
          var_name = 'CK_ENV_WEIGHTS_' + str(file_index)
          new_env[var_name] = os.path.join(WEIGHTS_DIR, file_name)
          files_to_push.append('$<<' + var_name + '>>$')
          file_index += 1
  else:
    new_env['CK_ENV_WEIGHTS_DIR'] = WEIGHTS_DIR
    new_env['CK_ENV_LABELS_FILE'] = os.path.join('..', LABELS_FILE)

  new_env['CK_ENV_RESOLUTION'] = dep_env('weights', 'CK_ENV_MOBILENET_RESOLUTION')
  new_env['CK_ENV_MULTIPLIER'] = dep_env('weights', 'CK_ENV_MOBILENET_MULTIPLIER')

  return {'return': 0, 'new_env': new_env, 'run_input_files': files_to_push}

