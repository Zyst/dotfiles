# Path to your oh-my-zsh installation.
export ZSH=/Users/zyst/.oh-my-zsh

ZSH_THEME=""

# Pure prompt configuration
autoload -U promptinit; promptinit

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias ls='ls -GFh'

# go things
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$HOME/Programming/dotfiles/path

# GRC go test
alias go="grc go"

# Turn off Display
alias sleep="pmset displaysleepnow"

# Hub makes you better at Github
alias git=hub

prompt pure
