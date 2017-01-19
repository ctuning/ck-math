#! /bin/bash

#
# Extra installation script
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, grigori.fursin@cTuning.org, 2017
#

# Weirdly, cmake does not copy the library to install dir, so doing this manually...

mkdir -p ${INSTALL_DIR}/install/lib

cp -f ${INSTALL_DIR}/obj/libviennacl/libviennacl.* ${INSTALL_DIR}/install/lib

if [ "$?" != "0" ]; then
  echo "Error: failed installing ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi

return 0
