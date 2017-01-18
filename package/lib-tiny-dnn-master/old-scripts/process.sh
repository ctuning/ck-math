#! /bin/bash

#
# Installation script for CK packages.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, 2016
#

# PACKAGE_DIR
# INSTALL_DIR


echo ""
echo "Cloning Package from GitHub ..."

git clone $PACKAGE_URL ${INSTALL_DIR}/src

echo ""
echo "Updating Package from GitHub ..."

cd ${INSTALL_SRC_DIR}/src
git pull

exit 0
