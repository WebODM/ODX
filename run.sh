#!/bin/bash

RUNPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -e $RUNPATH/venv ]; then
    source $RUNPATH/venv/bin/activate
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RUNPATH/SuperBuild/install/lib
export DYLD_LIBRARY_PATH=$RUNPATH/SuperBuild/install/lib

# Experimental: use jemalloc instead of the system's memory allocator
if [ "$ODX_JEMALLOC" = "YES" ]; then
    JEMALLOC=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
    if [ -e "$JEMALLOC" ]; then
        export LD_PRELOAD="$JEMALLOC"
        echo "ODX_JEMALLOC is set: using jemalloc as the memory allocator (experimental)"
    else
        echo "ODX_JEMALLOC is set, but jemalloc is not available on this system: using the default memory allocator"
    fi
fi

python3 $RUNPATH/run.py "$@"

