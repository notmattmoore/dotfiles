#!/bin/sh
# vsh = vim shell
# Read from standard input, put it in a vim instance, and then execute the
# results upon exit. Log all things run this way.
# Usage: vsh [--no-log] [--last|-l|--history|-h|--execute|-e|<file>]
# Version: 2025-09-15

vim_cmd='vim -c "set noswapfile" -c "set noundofile" -c "set ft=zsh"'
script_header='read -q "?Run script? [y/N] " || exit'
logfile_base="$HOME/.log/vsh_"
logfile="$logfile_base$(date +%FT%T).log"

usage() { # {{{
cat <<EOF
Usage: $(basename $0) [--no-log] [--last|-l|--history|-h|--execute|-e|<file>]
EOF
}  # }}}

# option parsing  {{{
# defaults
script_src_cmd="cat /dev/stdin" # read from stdin (i.e. piped src)
use_tempfile=1                  # use a tempfile by default
do_log=1                        # log by default

while [ $# -gt 0 ]; do
  case "$1" in
    "--no-log")
      unset do_log
      ;;
    "-l" | "--last")
      script_src_cmd=""
      logfile_newest="$(ls "$logfile_base"* | sort | tail -n 1)"
      [ -n "$logfile_newest" ] && script_src_cmd="cat $logfile_newest"
      ;;
    "-h" | "--history")
      script_src_cmd=""
      for f in $(ls "$logfile_base"* | sort); do
        script_src_cmd="echo '# $f'; cat $f; echo ''; $script_src_cmd"
      done
      ;;
    "-e" | "--execute")
      script_src_cmd=""
      ;;
    "--help")
      usage && exit
      ;;
    *)
      [ ! -f "$1" ] && echo "file not found: $1" && exit 1
      script_src_cmd=""
      script_name="$1"
      unset use_tempfile
      ;;
  esac
  shift
done
#----------------------------------------------------------------------------}}}

# If a file isn't passed on the command line then use a temp file.
[ $use_tempfile ] && script_name="$(mktemp)"

# Load the script. Use a trap to get partial input for editing.
trap 'echo "\nvsh: caught CTRL-C" >> "$script_name"' 2
eval "$script_src_cmd" >> "$script_name"
trap - 2    # unset the trap

# Edit the script and log it (if needed).
eval "$vim_cmd" "$script_name" < /dev/tty
[ $do_log ] && (cat "$script_name" >> "$logfile")

# Execute the script (trap ctrl-c from inside zsh).
trap 'echo "\nvsh: caught CTRL-C"' 2
( echo "$script_header"; cat "$script_name" ) | sponge "$script_name"
zsh "$script_name"
trap - 2  # unset the trap

# Delete the script if it was a temp file.
[ $use_tempfile ] && rm "$script_name"
