# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Stops Ctrl+S from locking the terminal, stderr thrown away
stty -ixon 2> /dev/null

# Turns off the terminal bell
setterm -bfreq 0 2> /dev/null

# don't put duplicate lines in the history. See bash(1) for more options
# force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
        else
    color_prompt=
        fi
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    else

    alias ls='ls --color'
fi

# some more ls aliases
alias ll='ls -alhF'
alias new='ls -alhrtF'
alias la='ls -A'
alias l1='ls -1'
alias l='ls -CF'
alias gg='git status -s'
alias pytree='tree -I "*.pyc|__pycache__"'
alias pyclean='find . -name \*.pyc -delete'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Source my prompt line
. ~/.prompt


###### find the IP addresses that are currently online in your network
function localIps()
{
for i in {1..254}; do
    x=`ping -c1 -w1 192.168.0.$i | grep "%" | cut -d"," -f3 | cut -d"%" -f1 | tr '\n' ' ' | sed 's/ //g'`
    if [ "$x" == "0" ]; then
        echo "192.168.0.$i"
    fi
done
}

function netinfo()
{
echo "--------------- Network Information ---------------"
/sbin/ifconfig | awk /'inet addr/ {print $2}'
/sbin/ifconfig | awk /'Bcast/ {print $3}'
/sbin/ifconfig | awk /'inet addr/ {print $4}'
/sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
myip=`wget -qO- ifconfig.co`
echo "External IP: ${myip}"
echo "---------------------------------------------------"
}

function settitle()
{
    echo -ne "\033]0;$@\007"
}

function streetlife()
{
    if [ -d ~/Projects/streetlife ]; then
        cd ~/Projects/streetlife/streetlife
        vim
    elif [ -d ~/slife ]; then
        cd ~/slife/site
        vim
    else
        echo "Wrong machine, probably"
    fi
}

function vpn()
{
    sudo openvpn --config ~/.openvpn/client.ovpn --auth-user-pass ~/.openvpn/auth.txt
}

function lock-screen()
{
    dbus-send --type=method_call --dest=org.gnome.ScreenSaver \
        /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock
}

function redshift()
{
    PGPASSWORD=$REDSHIFT_PASSWORD psql -h production-cluster.cdvjdjrwhppj.eu-west-1.redshift.amazonaws.com -U tsuser -d tsevents -p 5439
}



function search()
{
    sudo ls -R / | awk '
    /:$/&&f{s=$0;f=0}
    /:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
    NF&&f{ print s"/"$0 }' | grep -i "$1"
}

function android-simulation-starts()
{
    ts redshift --query \
        "SELECT DATE_TRUNC('day', received), COUNT(received) FROM api_requests WHERE (received BETWEEN CURRENT_DATE - '32 days'::INTERVAL AND CURRENT_DATE) AND user_agent LIKE 'okhttp%' AND endpoint = 'api-v3:phase-detail' GROUP BY date_trunc ORDER BY date_trunc ASC;"
}

function ios-simulation-starts()
{
    ts redshift --query \
        "SELECT DATE_TRUNC('day', received), COUNT(received) FROM api_requests WHERE (received BETWEEN CURRENT_DATE - '32 days'::INTERVAL AND CURRENT_DATE) AND user_agent LIKE '%CFNetwork%' AND endpoint = 'api-v3:phase-detail' GROUP BY date_trunc ORDER BY date_trunc ASC;"
}

# Of course we need to do this
export EDITOR=vim
export GOPATH=/home/hansel/Projects

# Caps lock is another escape key! Wheee!
setxkbmap -option caps:escape

# Source any sensitive tokens/variables
. ~/.sensitive

# I don't need to cache these folders...
PYTHONDONTWRITEBYTECODE=1

# Add our go install to the path
export PATH=$PATH:/usr/local/go/bin

