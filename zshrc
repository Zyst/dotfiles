# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME=""

# Pure prompt configuration
autoload -U promptinit; promptinit

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias ls='ls -GFh'

alias whost='sudo vim /mnt/c/Windows/System32/drivers/etc/hosts'

# go things
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# GRC go test
alias go="grc go"

# Turn off Display
alias sleep="pmset displaysleepnow"

# Hub makes you better at Github
alias gst="git status"

# update stuff
alias update="brew update && brew upgrade && npm update -g"

prompt pure
