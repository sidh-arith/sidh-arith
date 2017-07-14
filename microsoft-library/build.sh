#!/bin/sh
cd SIDH_v1.0
make clean
#make ARCH=x64 CC=gcc ASM=FALSE GENERIC=TRUE
make ARCH=x64 CC=gcc ASM=TRUE GENERIC=FALSE
