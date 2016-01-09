#!/bin/bash
set -eu -o pipefail
shopt -s failglob

cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

info () {
    printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
    printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
    printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
    echo ''
    exit
}

map_symlinks() {
    for link in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*'); do
        FILE=${link%.symlink}
        SOURCE="$link"
        TARGET="$HOME/.$(basename $FILE)"

        $1 $SOURCE $TARGET
    done
}

is_symlinked() {
    SOURCE=$1
    TARGET=$2

    if [[ -h "$TARGET" ]]; then
        LOCAL_TARGET=$(readlink ${TARGET})

        if [[ "$LOCAL_TARGET" == "$SOURCE" ]]; then
            return 0
        fi
    fi

    return 1
}

remove_symlink() {
    SOURCE=$1
    TARGET=$2

    if is_symlinked $SOURCE $TARGET; then
        rm $TARGET
        success "Removing symlink $TARGET"
    fi

    if [[ -e "$TARGET.backup" ]]; then
        mv "$TARGET.backup" "$TARGET"
        success "Restored backup $TARGET"
    fi
}

create_symlink() {
    SOURCE=$1
    TARGET=$2

    local skip=
    local backup=
    local overwrite=

    if [[ -e "$TARGET" ]]; then
        if is_symlinked $SOURCE $TARGET; then
            skip=true
        elif [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
            user "File already exists: ${TARGET}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
            read -r -n1 OPTION

            case "$OPTION" in
                "s") skip=true ;;
                "S") skip_all=true ;;
                "o") overwrite=true ;;
                "O") overwrite_all=true ;;
                "b") backup=true ;;
                "B") backup_all=true ;;
            esac
        fi
    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]; then
        rm -rf "$TARGET"
        success "removed $TARGET"
    fi

    if [ "$backup" == "true" ] && [ -e "$TARGET" ]; then
        mv "$TARGET" "${TARGET}.backup"
        success "moved $TARGET to ${TARGET}.backup"
    fi

    if [ "$skip" == "true" ]; then
        success "skipped $SOURCE"
    fi

    if [ "$skip" != "true" ]; then
        ln -s "${SOURCE}" "${TARGET}"
        success "linked ${SOURCE} to ${TARGET}"
    fi
}

dotfiles_install() {
    local overwrite_all=false
    local backup_all=false
    local skip_all=false

    map_symlinks create_symlink
}

dotfiles_remove() {
    map_symlinks remove_symlink
}

if [[ $# -eq 0 ]]; then
  MODE=install
else
  MODE=$1
fi

if [[ "$MODE" == "install" ]]; then
    dotfiles_install
elif [[ "$MODE" == "remove" ]]; then
    dotfiles_remove
else
    echo "What am I meant to be doing?"
fi
