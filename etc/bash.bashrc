# /etc/bash.bashrc for SuSE Linux
#
# PLEASE DO NOT CHANGE /etc/bash.bashrc There are chances that your changes
# will be lost during system upgrades.

#
# Check which shell is reading this file
#
if test -z "$is" ; then
  case "`ls -l /proc/$$/exe`" in
    */bash)	is=bash ;;
    */rbash)	is=bash ;;
    */ash)	is=ash  ;;
    */ksh)	is=ksh  ;;
    */zsh)	is=zsh  ;;
    */*)	is=sh   ;;
  esac
fi

#
# Colored file listings
#
if test -x /usr/bin/dircolors ; then
    #
    # set up the color-ls environment variables:
    #
    if test -f $HOME/.dir_colors ; then
	eval `dircolors -b $HOME/.dir_colors`
    elif test -f /etc/DIR_COLORS ; then
	eval `dircolors -b /etc/DIR_COLORS`
    fi
fi

#
# ls color option depends on the terminal
#
if test "$UID" = 0 ; then
    LS_OPTIONS='-a -N --color=tty -T 0';
else
    LS_OPTIONS='-N --color=tty -T 0';
fi

#
# Avoid trouble with Emacs shell mode
#
if test "$EMACS" = "t" ; then
    LS_OPTIONS='-N --color=none -T 0';
    tset -I -Q
    stty cooked pass8 dec nl -echo
fi
export LS_OPTIONS

#
# Set prompt and aliases to something useful for an interactive shell
#
case "$-" in
*i*)
    #
    # Some useful functions
    #
    startx  () { /usr/X11R6/bin/startx ${1+"$@"} 2>&1 | tee $HOME/.X.err ; }
    remount () { /bin/mount -o remount ${1+"$@"} ; }

    #
    # Set prompt to something useful
    #
    case "$is" in
    bash)
#	set -P
	set -p
	if test "$UID" = 0 ; then
	    PS1="\h:\w # "
	else
	    PS1="\u@\h:\w> "
	fi
#	# Returns short path (last two directoeries)
	spwd () {
	  ( IFS=/
	    set $PWD
	    if test $# -le 3 ; then
		echo "$PWD"
	    else
		eval echo \"..\${$(($# - 1))}/\${$#}\"
	    fi ) ; }
#	if test "$UID" = 0 ; then
#	    PS1="\h:\$(spwd) # "
#	else
#	    PS1="\u@\h:\$(spwd)> "
#	fi
#	# With physical path even if reached over sym link
#	if test "$UID" = 0 ; then
#	    PS1="\h:\$(pwd -P) # "
#	else
#	    PS1="\u@\h:\$(pwd -P)> "
#	fi
	;;
    ash)
	cd () {
	    local ret
	    command cd "$@"
	    ret=$?
	    PWD=$(pwd)
	    if test "$UID" = 0 ; then
		PS1="${HOST}:${PWD} # "
	    else
		PS1="${USER}@${HOST}:${PWD}> "
	    fi
	    return $ret
	}
	cd .
	;;
    ksh)
	if test "$UID" = 0 ; then
	    PS1="${HOST}:"'${PWD}'" # "
	else
	    PS1="${USER}@${HOST}:"'${PWD}'"> "
	fi
	;;
    zsh)
#	setopt chaselinks
	if test "$UID" = 0; then
	    PS1='%n@%m:%~ # '
	else
	    PS1='%n@%m:%~> '
	fi
	;;
    *)
#	PS1='\u:\w\$ '
	PS1='\h:\w\$ '
	;;
    esac
    PS2='> '

    if test "$is" = "ash" ; then
	# The ash shell does not have an alias builtin in
	# therefore we use functions here. This is a seperate
	# file because other shells may run into trouble
	# if they parse this even if they do not expand.
	test -s /etc/profile.d/alias.ash && . /etc/profile.d/alias.ash
    else
	unalias ls 2>/dev/null
	if test "$is" = "zsh" ; then
	    alias ls='eval /bin/ls $LS_OPTIONS'
	else
	    alias ls='ls $LS_OPTIONS'
	fi
	alias dir='ls -l'
	alias ll='ls -l'
	alias la='ls -la'
	alias l='ls -alF'
	alias ls-l='ls -l'

	#
	# Set some generic aliases
	#
	alias o='less'
	alias ..='cd ..'
	alias ...='cd ../..'
	if test "$is" != "ksh" ; then
	    alias -- +='pushd .'
	    alias -- -='popd'
	fi
	alias rd=rmdir
	alias md='mkdir -p'
	alias unix2dos='recode lat1..ibmpc'
	alias dos2unix='recode ibmpc..lat1'
	alias which='type -p'
	alias rehash='hash -r'
	if test "$is" != "ksh" ; then
	    alias beep='echo -en "\007"' 
	else
	    alias beep='echo -en "\x07"'
	fi
	alias unmount='echo "Error: Try the command: umount" 1>&2; false'
    fi
    test -s $HOME/.alias && . $HOME/.alias

    # Do not save dupes in the bash history file
    HISTCONTROL=ignoredups
    if test "$is" = "ksh" ; then
	# Use a ksh specific history file and enable
    	# emacs line editor
    	HISTFILE=$HOME/.kshrc_history
    	VISUAL=emacs
    fi
    ;;
esac

#
# End of /etc/bash.bashrc
#