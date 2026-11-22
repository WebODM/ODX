#!/bin/bash

RUNPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -e $RUNPATH/venv ]; then
    source $RUNPATH/venv/bin/activate
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RUNPATH/SuperBuild/install/lib
export DYLD_LIBRARY_PATH=$RUNPATH/SuperBuild/install/lib

# Optional: use mimalloc instead of the system's memory allocator
if [ "$ODX_MIMALLOC" = "YES" ]; then
    MIMALLOC=/usr/lib/$(uname -m)-linux-gnu/libmimalloc.so.2
    if [ -e "$MIMALLOC" ]; then
        export LD_PRELOAD="$MIMALLOC"
        echo "ODX_MIMALLOC is set: using mimalloc as the memory allocator"
    else
        echo "ODX_MIMALLOC is set, but mimalloc is not available on this system: using the default memory allocator"
    fi
fi

python3 $RUNPATH/run.py "$@"

