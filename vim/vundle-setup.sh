#!/bin/sh
VUNDLE_DIR=~/.vim/bundle/vundle

if [[ ! -d "$VUNDLE_DIR" ]]; then
    mkdir -p $VUNDLE_DIR
    git clone https://github.com/gmarik/Vundle.vim.git $VUNDLE_DIR
fi
