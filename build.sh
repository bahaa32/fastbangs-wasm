#! /bin/bash

# This script will build the wasm module and package it into a Firefox extension.
# It requires wasm-pack and zip to be installed. All output will be placed in $OUTDIR.
# Use this instead of cargo if you want to build the extension instead of just
#  the wasm module.

OUTDIR=./out/data/
EXTDIR=./ext

mkdir -p $OUTDIR
wasm-pack build --release -t no-modules -d $OUTDIR
cat $EXTDIR/runner.js >> $OUTDIR/fastbangs_wasm.js
cp $EXTDIR/manifest.json $OUTDIR/manifest.json
cd $OUTDIR && zip -r ../fastbangs.xpi .
