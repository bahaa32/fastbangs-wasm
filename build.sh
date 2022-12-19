#! /bin/bash

# This script will build the wasm module and package it into a Firefox extension.
# All output will be placed in $OUTDIR. Use this instead of cargo if you want to
# build the extension instead of just the wasm module.

# Usage:
#   ./build.sh [docker|clean]
#   docker: Build the extension through docker (requires docker)
#   clean: Remove the output directory
#   (no args): Build the extension locally (requires rustup, wasm-pack and zip)

OUTDIR=./out/
EXTDIR=./ext

mkdir -p $OUTDIR

if [ "$1" = "docker" ]; then
    docker build --output out/ . -t fastbangs-build
elif [ "$1" = "clean" ]; then
    rm -rf $OUTDIR
    echo "Removed $OUTDIR"
else
    wasm-pack build --release -t no-modules -d $OUTDIR/data
    cat $EXTDIR/runner.js >> $OUTDIR/data/fastbangs_wasm.js
    cp $EXTDIR/manifest.json $OUTDIR/data/manifest.json
    cd $OUTDIR/data && zip -r ../fastbangs.xpi .   
fi;
