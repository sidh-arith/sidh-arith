#!/bin/sh
make clean
#make ARCH=x64 CC=gcc ASM=FALSE GENERIC=TRUE
make -B ARCH=x64 CC=gcc ASM=TRUE GENERIC=FALSE
