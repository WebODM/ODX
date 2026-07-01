#!/bin/bash

RUNPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -e $RUNPATH/venv ]; then
    source $RUNPATH/venv/bin/activate
fi
if [ "$(uname)" == "Linux" ]; then
   if [ -f "/usr/lib/x86_64-linux-gnu/libtcmalloc.so" ]; then
      export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so
   else
      echo "Can't find libtcmalloc. tcmalloc is mandatory for running ODX."
      exit 1
   fi
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RUNPATH/SuperBuild/install/lib
export DYLD_LIBRARY_PATH=$RUNPATH/SuperBuild/install/lib
python3 $RUNPATH/run.py "$@"

