#!/bin/bash

# Make sure we can reach our library via lib/ when it is actually in lib64/

if [ -d "$INSTALL_DIR/install/lib64" ] && ! [ -d "$INSTALL_DIR/install/lib" ]; then
    ln -s lib64 "$INSTALL_DIR/install/lib"
fi
