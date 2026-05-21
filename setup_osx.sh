#!/bin/sh

cd third_party/

echo "==== Installing dependencies ===="

if [ ! -d build ]; then
mkdir build
fi

cd build
cmake ../SDL3-3.4.4
make -j
cd ../..


