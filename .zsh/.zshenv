# This file gets sources by all invocations of zsh, including scripts and
# interactive shells.

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
# Aliases and builtins {{{1
autoload -Uz zmv          # programmable moving

# QoL
alias bc="bc -ql"
alias cp="cp --reflink=auto -i"
# alias crontab="crontab -i"  # see crontab function below (use yaml-to-systemd instead)
alias datediff="dateutils.ddiff"
alias dateseq="dateutils.dseq"
alias firefox="firefox --new-window"
alias info="info --vi-keys"
alias less="less --mouse --ignore-case --chop-long-lines --shift .25 --LINE-NUMBERS --follow-name"
alias locate="locate --regex"
alias mkdir="mkdir -p"
alias mutt="cd ~/tmp/; mutt; cd -"
alias mv="mv -i"
alias rg="rg --no-messages --smart-case"
alias sxiv="sxiv -a -o -s f"
alias zathura="zathura --fork"

# custom commands
alias history="fc -i -n -l 1 -1" # show full history
function crontab() { print "Use\n  $ yaml-to-systemd --user ~/.cronfile.yaml\ninstead." }
alias git-dotfiles="git --git-dir=$HOME/.git-dotfiles --work-tree=$HOME"
alias map="xargs -I % --"        # xargs shortcut
alias onlyx="startx & vlock"
alias pdflatexmk="latexmk -pvc -f -silent -pdflatex -synctex=1"
alias rsend="rsync -ahz --partial --info=progress2"
alias vess="vim -c 'set number' -"
alias vim-git="vim -c 'Git' -c 'wincmd o'"
alias vim-git-dotfiles="GIT_DIR=~/.git-dotfiles vim-git"
function vman() { vim -c "Man $@|only"; }
alias vnice="nice -n 20 ionice -c 3"
#----------------------------------------------------------------------------}}}1
