#
# Copyright (c) 2018 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#   

import os

def setup(i):
    """
    Input:  {
              cfg              - meta of this soft entry
              self_cfg         - meta of module soft
              ck_kernel        - import CK kernel module (to reuse functions)

              host_os_uoa      - host OS UOA
              host_os_uid      - host OS UID
              host_os_dict     - host OS meta

              target_os_uoa    - target OS UOA
              target_os_uid    - target OS UID
              target_os_dict   - target OS meta

              target_device_id - target device ID (if via ADB)

              tags             - list of tags used to search this entry

              env              - updated environment vars from meta
              customize        - updated customize vars from meta

              deps             - resolved dependencies for this soft

              interactive      - if 'yes', can ask questions, otherwise quiet
            }

    Output: {
              return       - return code =  0, if successful
                                         >  0, if error
              (error)      - error text if return > 0

              bat          - prepared string for bat file
            }

    """

    ck = i['ck_kernel']

    cus = i.get('customize',{})
    full_path = cus.get('full_path','')
    env = i['env']
    ep = cus['env_prefix']
    host_os_dict = i.get('host_os_dict', {})
    target_os_dict = i.get('target_os_dict', {})
    target_os_name = target_os_dict.get('ck_name2', '')
    s = ''

    lib_dir = os.path.dirname(full_path)
    install_dir = os.path.dirname(lib_dir)
    ck_tools_dir = os.path.dirname(install_dir)

    env[ep] = ck_tools_dir
    env[ep+'_LIBS'] = '-lmace'
    env[ep+'_LIB_DIRS'] = '-L'+os.path.join(lib_dir)
    env[ep+'_INCLUDE0'] = os.path.join(install_dir, 'include')

    return {'return': 0, 'bat': ''}
