#!/bin/bash
set -eu -o pipefail
shopt -s failglob

dotfiles_install() {
    backup_all=false
    overwrite_all=false

    RPWD=$(realpath $PWD)

    for link in */*.symlink
    do
        FILE=${link%.symlink}
        SOURCE="$RPWD/$link"
        TARGET="$HOME/.$(basename $FILE)"

        backup=false
        overwrite=false

        echo "$SOURCE -> $TARGET"

        if [[ -e "$TARGET" ]]; then
            echo "File already exists: ${TARGET}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
            read -r -n1 OPTION

            case "$OPTION" in
                "s") continue ;;
                "S") exit ;;
                "o") overwrite=true ;;
                "O") overwrite_all=true ;;
                "b") backup=true ;;
                "B") backup_all=true ;;
             esac

             [[ $backup || $backup_all ]] && mv "$TARGET" "$TARGET.backup"
             [[ $overwrite || $overwrite_all ]] && rm -rf "$TARGET"
        fi

        ln -s "$SOURCE" "$TARGET"
        echo "$SOURCE -> $TARGET"
    done
}

dotfiles_remove() {
    RPWD=$(realpath $PWD)

    for link in */*.symlink
    do
        FILE=${link%.symlink}
        SOURCE="$RPWD/$link"
        TARGET="$HOME/.$(basename $FILE)"

        if [[ -h "$TARGET" ]]; then
            rm $TARGET
        fi

        if [[ -e "$TARGET.backup" ]]; then
            mv "$TARGET.backup" "$TARGET"
        fi
    done
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
