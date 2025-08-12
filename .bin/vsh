#!/bin/sh
# vsh = vim shell
# Read from standard input, put it in a vim instance, and then execute the
# results upon exit. Log all things run this way.
# Usage: vsh [--no-log] [--last|-l|--history|-h|--execute|-e|<file>]
# Version: 2025-08-12

vim_cmd='vim -c "set noswapfile" -c "set noundofile" -c "set ft=zsh"'
script_header='read -q "?Run script? [y/N] " || exit'
logsep_top="# -- $(date +%F\ %T) ----------------------------------------------------------------"
logsep_bot="# ------------------------------------------------------------------------------"
logfile="$HOME/.log/vsh.log"

usage() { # {{{
cat <<EOF
Usage: $(basename $0) [--no-log] [--last|-l|--history|-h|--execute|-e|<file>]
EOF
}  # }}}
newest_log() {  # {{{
  if [ -f "$logfile" ]; then
    echo "$logfile"
  else
    ls "$logfile"* | sort | tail -n 1
  fi
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
      script_src_cmd="tac $(newest_log) \
        | sed -r '2,/^-.{25}-{54}$/!d' \
        | head -n -1 \
        | tac"
      ;;
    "-h" | "--history")
      script_src_cmd="cat $(newest_log)"
      ;;
    "-e" | "--execute")
      script_src_cmd=""
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
[ $do_log ] && ( echo "$logsep_top"; cat "$script_name"; echo "$logsep_bot" ) >> "$logfile"

# Execute the script (trap ctrl-c from inside zsh).
trap 'echo "\nvsh: caught CTRL-C"' 2
( echo "$script_header"; cat "$script_name" ) | sponge "$script_name"
zsh "$script_name"
trap - 2  # unset the trap

# Delete the script if it was a temp file.
[ $use_tempfile ] && rm "$script_name"
