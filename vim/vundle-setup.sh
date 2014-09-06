#!/bin/sh
VUNDLE_DIR=~/.vim/bundle/vundle

if [[ ! -d "$VUNDLE_DIR" ]]; then
    mkdir -p $VUNDLE_DIR
    git clone http://github.com/gmarik/vundle.git $VUNDLE_DIR
fi
