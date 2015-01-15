#!/bin/sh
BIN_DIR=~/bin
SELECTA_DIR=$(mktemp -d)

if [[ ! -d "$BIN_DIR" ]]; then
    mkdir -p $BIN_DIR
fi

if [[ ! -d "$BIN_DIR/selecta" ]]; then
    git clone https://github.com/garybernhardt/selecta.git $SELECTA_DIR
    mv $SELECTA_DIR/selecta ~/bin/selecta
fi

rm -rf $SELECTA_DIR
