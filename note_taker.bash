#!/usr/bin/env bash
#
# note taker executable

NOTE_PAD_PATH="/$HOME/.notes_for_note_taker.txt"

# editor set this here or through git
# $ git config --global core.editor "emacs"
EDITOR=$(git config core.editor 2> /dev/null || echo 'vim')

#######################################
# Script to test
# Globals:
#   NOTE_PAD_PATH
# Arguments:
#   $@
# Returns:
#   None
#######################################
testing () {
    echo "$#"
    if [ "$#" == 1 ] && [ "$1" == "-i" ]; then
        # -i for interactive
        echo "-i"
        [[ "$0" = "$BASH_SOURCE" ]] && exit 0 || return 0
    elif [ "$#" == 1 ] && [ "$1" == "-e" ]; then
        # -e for edit
        echo "1 = 1"
        [[ "$0" = "$BASH_SOURCE" ]] && exit 0 || return 0
    else
        echo "else"
    fi
    for var in "${@:2}"; do
        echo "$var"
    done
}

#######################################
# Handles options
# Globals:
#   NOTE_PAD_PATH
#   EDITOR
# Arguments:
#   -p: paste from pbpaste
#   -i: interactive option, adds timestamp
#   -e: edit file, does not add timestamp
#   -t N: output $ tail -n (optional N number of lines)
# Returns:
#   None
#######################################
handle_options () {
    case "$1" in
        "-p")
            # -p for paste
            printf "\n" >> "$NOTE_PAD_PATH"
            date >> "$NOTE_PAD_PATH"
            echo -n "(clipboard)--: $(pbpaste)" >> "$NOTE_PAD_PATH"
            printf "\n" >> "$NOTE_PAD_PATH"
            ;;
        "-i")
            # -i for interactive
            printf "\n" >> "$NOTE_PAD_PATH"
            date >> "$NOTE_PAD_PATH"
            echo -n "----: " >> "$NOTE_PAD_PATH"
            "$EDITOR" "$NOTE_PAD_PATH"
            ;;
        "-e")
            # -e for edit
            "$EDITOR" "$NOTE_PAD_PATH"
            ;;
        "-f")
            # -f S for find using grep with string match for S
            if [[ -z "$2" ]]; then
                echo "Usage: $ note -f 'STRING_TO_FIND'"
            else
                cat "$NOTE_PAD_PATH" | grep --ignore-case --before-context=3 --after-context=3 --color --extended-regexp "$2"
            fi
            ;;
        "-t")
            # -t N for tail -n N (optional)
            if [[ -z "$2" ]]; then
                tail "$NOTE_PAD_PATH"
            else
                tail -n $2 "$NOTE_PAD_PATH"
            fi
            echo ""
            ;;

        "-u")
            # -u for undo: deletes last note
            read -p "Delete last note [y/n]? " -n 1 -r CLEAR_REPLY
            echo ""
            if [[ ! "$CLEAR_REPLY" =~ ^[Yy]$ ]]; then
              echo "Cancelled."
            else
              #Clear last note in file:
              #Get the last non-blank line in the notes file
              LINE_NUMBER = (wc -l "$NOTE_PAD_PATH") - 1
              #Copy the text of the last non-blank file to a variable
              LINE_TEXT = tail -n +$LINE_NUMBER "$NOTE_PAD_PATH" | head -n 1
              #As long as the variable holding the last line is not blank:
              until [ -z "$LINE_TEXT" ]; do
                #Delete the last line of the notepad file
                head -n -1 "$NOTE_PAD_PATH" > temp.txt
                mv temp.txt "$NOTE_PAD_PATH"
                #Decrement the line number variable
                LINE_NUMBER = (wc -l "$NOTE_PAD_PATH")
                #Get the text of the new last line
                LINE_TEXT = tail -n +$LINE_NUMBER "$NOTE_PAD_PATH" | head -n 1
              done
              rm temp.txt
            fi
            echo ""
            ;;

        "-c")
            # -c for clear notes
            read -p "Clear all notes [y/n]? " -n 1 -r CLEAR_REPLY
            echo ""
            if [[ ! "$CLEAR_REPLY" =~ ^[Yy]$ ]]; then
              echo "Cancelled."
            else
              #Clear notes file:
              > "$NOTE_PAD_PATH"
            fi
            echo ""
            ;;

        *)
            return
            ;;
    esac
    [[ "$0" = "$BASH_SOURCE" ]] && exit 0 || return 0
}

#######################################
# Writes arguments to notepad
# Globals:
#   NOTE_PAD_PATH
# Arguments:
#   $1: the subject line or Options
#   $@: all notes
# Returns:
#   None
#######################################
process_notes () {
    argv_one_length=${#1}
    if [[ "$argv_one_length" == 2 ]]; then
        handle_options "$@"
    elif [[ "$argv_one_length" == 0 ]]; then
        echo "Usage: $ note [pieft] [NS] [<SUBJECT>] [<MESSAGE_LINE_1>] [<MESSAGE_LINE_2>] ..."
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi
    date >> "$NOTE_PAD_PATH"
    echo "----: $1" >> "$NOTE_PAD_PATH"

    # Loop all argv args after first to last
    for var in "${@:2}"; do
        echo "$var" >> "$NOTE_PAD_PATH"
    done
    printf "\n" >> "$NOTE_PAD_PATH"
}

process_notes "$@"
#testing "$@"
