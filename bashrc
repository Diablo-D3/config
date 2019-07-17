#!/bin/bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2034


# environment
PATH=$HOME/bin:node_modules/.bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/mingw64/bin:$JAVA_HOME/bin:$PATH

LC_CTYPE=en_US.UTF-8

EDITOR=vim
VISUAL=vim
GIT_EDITOR=vim

[ -z "$PS1" ] && return
shopt -oq posix && return

if [[ -a ~/.bashrc.local ]]; then
	. ~/.bashrc.local
fi

shopt -s checkwinsize
shopt -s globstar 2> /dev/null
shopt -s nocaseglob
shopt -s histappend
shopt -s cmdhist
shopt -s lithist

HISTSIZE=999999999
HISTFILESIZE=999999999
HISTCONTROL="erasedups:ignoreboth"

export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"


# aliases
alias grep="grep --color=auto"
alias ls="ls --color=auto"


# completion
bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind "set show-all-if-ambiguous on"
bind "set mark-symlinked-directories on"

if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# base16
BASE16_SHELL=$HOME/config/base16-shell/
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && eval "$("$BASE16_SHELL/profile_helper.sh")"
base16_bright


# colors
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
GREY=$(tput setaf 8)
ORANGE=$(tput setaf 16)
BROWN=$(tput setaf 17)


# hostname color
case $HOSTNAME in
infinity*)
	PRO_FG=$BLUE
	;;
chaos*)
	PRO_FG=$CYAN
	;;
absolute*)
	PRO_FG=$GREEN
	;;
*)
	BANNEDCOLOR=(0 124 231 234 238)

	HOSTCHECKSUM=$(echo "$HOSTNAME" | md5sum)
	HOSTCOLOR=0
	I=1
	J=2

	while (printf '%s\n' "${BANNEDCOLOR[@]}" | grep -xq $HOSTCOLOR); do
		HOSTCOLORBYTE=$(echo "$HOSTCHECKSUM" | cut -b"$I"-"$J")
		HOSTCOLOR=$(printf '%d' "0x$HOSTCOLORBYTE")

		I=$((I + 1))
		J=$((J + 1))
	done

	PRO_FG=$(tput setaf "$HOSTCOLOR")

	unset BANNEDCOLOR
	unset HOSTCHECKSUM
	unset HOSTCOLOR
	unset HOSTCOLORBYTE
	unset I
	unset J
	;;
esac


# git prompt
GIT_PS1_SHOWCOLORHINTS=true
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=auto

if [[ -a /usr/share/git/completion/git-prompt.sh ]]; then
	. /usr/share/git/completion/git-prompt.sh
elif [[ -a /usr/lib/git-core/git-sh-prompt ]]; then
	. /usr/lib/git-core/git-sh-prompt
fi


# prompt theme
PRO_START="[\\[$PRO_FG\\]\\h\\[$RESET\\] \\W"

if [ "$(id -u)" -eq 0 ]; then
    PRO_END="]\\[$RED\\]#\\[$RESET\\] "
else
    PRO_END="]\$ "
fi

precmd() {
	if [[ x$PWD != x$HOME ]] && [ x"$(type -t __git_ps1)" = x'function' ]; then
		__git_ps1 "$PRO_START" "$PRO_END"
	else
		PS1=$PRO_START$PRO_END
	fi

	if [[ -n $TMUX ]]; then
		eval "$(tmux show-environment -s)"
	fi

	history -a
}

PROMPT_COMMAND=precmd

preexec() {
	if [[ $BASH_COMMAND == "precmd" ]]; then
		COMMAND=${DIRSTACK[*]}
	else
		COMMAND=$BASH_COMMAND
	fi

	PRO_TITLE="\\033]0;${HOSTNAME%%.*}: $COMMAND\\007"
	echo -ne "$PRO_TITLE"
}

trap preexec DEBUG
