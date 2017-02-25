#! /bin/bash

#
# Post-cloning installation script.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, grigori.fursin@ctuning.org, 2017.
# - Anton Lokhmotov, anton@dividiti.com, 2017.
#

# Manually copy src/viennacl/ directory under install/include/.

mkdir -p ${INSTALL_DIR}/install/include/

cp -r ${INSTALL_DIR}/src/viennacl/ ${INSTALL_DIR}/install/include/

if [ "$?" != "0" ]; then
  echo "Error: failed installing ViennaCL ..."
  read -p "Press any key to continue!"
  exit $?
fi

return 0
