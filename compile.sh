#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

/usr/local/cuda/bin/nvcc -O3 -Xcompiler -Wno-write-strings -I. start.cu -o start -lcudart -I/usr/include/sfml -lsfml-graphics -lsfml-window -lsfml-system
