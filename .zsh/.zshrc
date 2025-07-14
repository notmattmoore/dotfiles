# Global exports {{{1
export PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin:$HOME/.bin:$HOME/.local/bin"
export ZDOTDIR="$HOME/.zsh"
export LC_ALL="C.UTF-8"
export EDITOR="vim"
export BROWSER="firefox"
export PDFVIEWER="zathura"
export GPG_TTY="$(tty)"               # the tty used by gpg
export _JAVA_AWT_WM_NONREPARENTING=1  # Java programs don't run nicely without this
export FZF_DEFAULT_OPTS="--layout=reverse \
  --inline-info \
  --cycle \
  --multi \
  --bind=alt-enter:print-query,ctrl-space:replace-query,right:replace-query"
#----------------------------------------------------------------------------}}}1
# Prompt {{{1
# valid colors are: red, green, yellow, blue, magenta, cyan, white
autoload -Uz colors zsh/terminfo && colors

# for reseting the formatting styles
PR_RESET_STYLE="%{$reset_color%}"

disp_user () { PR_USER="${PR_USER_STYLE}%n${PR_RESET_STYLE}:" }
disp_host () { PR_HOST="@${PR_HOST_STYLE}%m${PR_RESET_STYLE}:" }
disp_user_at_host () {
  disp_user
  PR_USER=${PR_USER%":"}
  disp_host
}

PR_LEFT_CHAR="("
PR_RIGHT_CHAR=")"
PR_PWD_STYLE="%{$terminfo[bold]%}"
PR_CHAR_STYLE="%{$terminfo[bold]%}"
PR_CHAR="∴"

if [ -n "$SSH_CONNECTION" ]; then
  PR_HOST_STYLE="%{$fg[magenta]%}"
  disp_host
  if [ "$(whoami)" != "mm" ]; then
    PR_USER_STYLE="%{$fg[magenta]%}"
    disp_user_at_host
  fi
fi
if [ -n "$SCHROOT_SESSION_ID" ]; then
  PR_USER_STYLE="%{$fg[magenta]%}"
  PR_HOST_STYLE="%{$fg[red]%}"
  disp_user_at_host
  PR_HOST="${PR_HOST%':'}[%{$fg[green]%}schroot${PR_RESET_STYLE}]:"
fi
if [ "$(whoami)" = "root" ]; then
  PR_USER_STYLE="%{$fg[red]%}"
  PR_CHAR_STYLE="%{$fg[red]%}"
  disp_user
fi

setopt prompt_subst
PROMPT="${PR_LEFT_CHAR}${PR_USER}${PR_HOST}${PR_PWD_STYLE}%~${PR_RESET_STYLE}${PR_RIGHT_CHAR} ${PR_CHAR_STYLE}${PR_CHAR}${PR_RESET_STYLE} "
#----------------------------------------------------------------------------}}}1
# History settings {{{1
HISTFILE="${ZDOTDIR}/zsh_history"
HISTSIZE=500000   # number of lines available in a session (must be >=SAVEHIST)
SAVEHIST=500000   # number of lines saved
setopt hist_find_no_dups   # don't match duped lines when giving history
setopt hist_ignore_space   # don't add lines starting with a ' ' to history
setopt extended_history    # save timestamp and duration information too
setopt share_history       # make history work with sessions
setopt hist_reduce_blanks  # clean up history file
#----------------------------------------------------------------------------}}}1
# Options {{{1
# misc
setopt auto_pushd           # automatically use the dir stack
setopt interactive_comments # allow comments in interactive mode
setopt extended_glob        # extra search patterns
setopt no_beep              # no beeping FFS

# completions
setopt correct          # correct spelling (use prompt below)
SPROMPT="Correct to %{$terminfo[bold]%}%r${PR_RESET_STYLE}? [ynae] "
setopt list_packed      # make completion list smaller
setopt no_nomatch       # don't error if no matches are found

# job control
stty stop undef         # disable C-s freezing
export REPORTTIME=30    # if command took more than 30s, say how long it took
setopt auto_continue    # background jobs are not killed
setopt no_bg_nice       # dont nice background jobs
setopt no_check_jobs    # dont bug me about backgrounded jobs
setopt no_hup           # dont hangup jobs
#----------------------------------------------------------------------------}}}1
# Key bindings {{{1
bindkey -v  # vim keybindings

# a widget to indicate which mode we are in on the prompt
function zle-line-init zle-keymap-select {
  RPROMPT="${${KEYMAP/vicmd/[CMD]}/(main|viins)/}"
  RPROMPT2=$RPROMPT
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# make jk go into cmd mode
bindkey -M viins 'jk' vi-cmd-mode

# make ctrl-e launch a full vim editor
autoload edit-command-line
zle -N edit-command-line
bindkey "\C-e" edit-command-line
bindkey -M vicmd "\C-e" edit-command-line

# search mappings (we always use vi-style search)
bindkey -M viins "\C-n" history-beginning-search-backward # C-n
bindkey -M viins "\C-p" history-beginning-search-forward  # C-p

# terminal-specific workarounds
case $TERM in
  # xterm doesn't seem to know home and end
  "xterm"*)
    bindkey "^[[H" beginning-of-line # home
    bindkey "^[[F" end-of-line       # end
  ;;
esac

# fzf widgets
function fzf-files {  # {{{
  # Widget to use fzf to find files.
  # We search based on the suffix of the buffer to the left of the cursor that
  # appears to be a path. find needs '~' to be replaced by the contents of
  # $HOME, so we do that, execute find, and then undo the replacement. To
  # further complicate things, special characters need to be escaped.

  HOME_escaped="$(echo "$HOME" | sed -e 's/[\/&]/\\&/g')"
  lbuffer_path="$(echo "$LBUFFER" | egrep -o '("[^ ][^"]*|([^ "]|\\ )*)$')"
  lbuffer_path_escaped="$(echo "$lbuffer_path" | sed -e 's/[\/&]/\\&/g')"
  lbuffer_path_derel="$(echo "$lbuffer_path" | sed "s/^~/$HOME_escaped/")"

  # 1: find everything relevant,
  # 2: undo the $HOME replacement, plus delete the leading ./ (if it's there),
  # 3: delete the *first* instance of the lbuffer path suffix so that it isn't
  #    duplicated on the command line
  find -L $lbuffer_path_derel \( -path '*/.*' -o -fstype 'sysfs' \
      -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \) -prune \
      -o -type f -o -type d -o -type l 2> /dev/null \
    | sed -e "s/^$HOME_escaped/~/" -e "s/\.\///" \
    | fzf-cmd --scheme=path \
    | sed -z -e "s/^$lbuffer_path_escaped//" \
    | fzf-buffer -q
}  # }}}
function fzf-history {  # {{{
  # Widget to use fzf to search the history.
  # Get the history, reverse it, then start fzf using the contents of the line
  # buffer as the initial search. If the search is successful, then replace the
  # buffer with the result.

  S="$( fc -i -n -l 1 -1 \
    | tac \
    | fzf-cmd --nth=2.. --scheme=history --tiebreak=index --query="$BUFFER" \
    | cut -d ' ' -f 4- )"

  [ -n "S" ] && BUFFER="$S"
  zle redisplay
}  # }}}
function fzf-processes {  # {{{
  # widget to filter list of processes
  ps -ef \
    | sed 1d \
    | tr -s ' ' \
    | cut -d ' ' -f 2,8- \
    | fzf-cmd --with-nth=2.. --preview 'echo {}' --preview-window down:3:wrap --height=15 \
    | awk '{print $1}' \
    | tr '\n' ' ' \
    | fzf-buffer
}  # }}}
function fzf-cmd {  # {{{
  # the actual fzf command
  fzf --border --height=12 $@
}  # }}}
function fzf-buffer { # {{{
  # helper function to append output of fzf to the buffer

  # fill an array with the returned lines. Inline and quote if necessary
  IFS=$'\n' items=( `cat` )
  for item in $items; do
    if [ "$1" = "-q" ]; then
      LBUFFER+="$item:q:gs/\\~/~/ "
    else
      LBUFFER+="$item "
    fi
  done
  LBUFFER="${LBUFFER% }"  # remove the space at the end
  zle redisplay           # refresh the line
}  # }}}
zle -N fzf-files
zle -N fzf-history
zle -N fzf-processes
if which fzf > /dev/null ; then
  bindkey -M viins "^f" fzf-files       # C-f
  bindkey -M viins "^_" fzf-history     # C-/
  bindkey -M viins "^[^k" fzf-processes   # C-A-k
fi
#----------------------------------------------------------------------------}}}1
# Aliases and builtins {{{1
eval $(dircolors -b)

autoload -Uz zmv          # programmable moving

# QOL
alias bc="bc -ql"
alias cp="cp --reflink=auto -i"
# alias crontab="crontab -i"  # see crontab function below (use yaml-to-systemd instead)
alias datediff dateutils.ddiff
alias dateseq dateutils.dseq
alias firefox="firefox --new-window"
alias info="info --vi-keys"
alias less="less --mouse --ignore-case --chop-long-lines --shift .25 --LINE-NUMBERS --follow-name"
alias locate="locate --regex"
alias mkdir="mkdir -p"
alias mv="mv -i"
alias rg="rg --no-messages --smart-case"
alias sxiv="sxiv -a -o -s f"
alias zathura="zathura --fork"

# colors
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias ip="ip --color=auto"
alias ls="ls --color=auto -hN --time-style=iso"

# custom commands
alias history="fc -i -n -l 1 -1" # show full history
function crontab() { print "Use\n  $ yaml-to-systemd --user ~/.cronfile.yaml\ninstead." }
alias git-dotfiles="git --git-dir=$HOME/.git-dotfiles"
alias map="xargs -I % --"        # xargs shortcut
alias onlyx="startx & vlock"
alias pdflatexmk="latexmk -pvc -f -silent -pdflatex -synctex=1"
alias rsend="rsync -ahz --partial --info=progress2"
alias vess="vim -c 'set number' -"
alias vim-git="vim -c 'Git' -c 'wincmd o'"
alias vim-git-dotfiles="GIT_DIR=~/.git-dotfiles vim-git"
function vman() { vim -c "Man $@|only"; }
alias vnice="nice -n 20 ionice -c 3"

# file shortcuts
alias accounts.gpg="vim-gpg ~/personal/accounts.gpg"
alias pii-matthew.gpg="vim-gpg ~/personal/records/personal-identity/matthew-notes.gpg"
alias logins.gpg="vim-gpg ~/technical/logins.gpg"
#----------------------------------------------------------------------------}}}1
# Completion {{{1
# cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZDOTDIR}/zsh_cache"
# complete using (in order) expansion, usual completion, ignored patterns, and then approximate
zstyle ':completion:*' completer _expand _complete _ignored _approximate
# if there is an unambiguous match, then insert it
zstyle ':completion:*:approximate:*' insert-unambiguous true
# allow 1/3rd of the string to be errors
zstyle ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) )'
# order the list case insensitively
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
# don't do completion for not installed commands
zstyle ':completion:*:functions' ignored-patterns '_*'

# color completions like ls
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# use a nice menu
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
# describe the type of each completion
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
# group matches by type name
zstyle ':completion:*' group-name ''

# application specific
compctl -/ -g "*.gpg" vim-gpg
compctl -/ -g "*.(pdf|ps|djvu)" zathura

autoload -Uz compinit
zmodload zsh/complist
compinit
#----------------------------------------------------------------------------}}}1
# Misc functions {{{1
# put the current working directory or the current program in the title bar
precmd () {
  case $TERM in
    tmux*|screen*) print -Pn -- "\ek%1~\e\\" ;;
    *) print -Pn "\e]0;%~\a" ;;
  esac
}
preexec () {
  case $TERM in
    tmux*|screen*) print -n "\ek${1}\e\\" ;;
    *) print -n "\e]0;${1}\a" ;;
  esac
}

# Either show the todo list or a quote (randomly) unless the QUIET is set.
if [ -z "$QUIET" ]; then
  if [ -s "$HOME/todo" ] && (($RANDOM % 2)); then
    todo -p
  elif ( command -v fortune > /dev/null ); then
    [ -d "$HOME/.fortunes" ] && fortune "$HOME/.fortunes" && echo -n "\n"
  fi
else
  unset QUIET
fi

# If RUN_FIRST is set then execute the variable contents first, entering an
# interactive shell once done.
[ -n $RUN_FIRST ] && eval ${RUN_FIRST} && unset RUN_FIRST
#----------------------------------------------------------------------------}}}1
