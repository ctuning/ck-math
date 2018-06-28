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

  new_env = {}
  files_to_push = []

  if i['target_os_dict'].get('remote','') == 'yes':
    # For Android weights and labels will be located near the executable
    new_env['CK_ENV_WEIGHTS_DIR'] = '.'
    new_env['CK_ENV_LABELS_FILE'] = LABELS_FILE

    # Set list of additional files to be copied to Android device.
    # We have to set these files via env variables with full paths 
    # in order to they will be copied into remote program dir without sub-paths.
    new_env['CK_ENV_LABELS_FILE_PATH'] = os.path.join(os.getcwd(), '..', LABELS_FILE)
    files_to_push.append("$<<CK_ENV_LABELS_FILE_PATH>>$")

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

  return {'return': 0, 'new_env': new_env, 'run_input_files': files_to_push}

