# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="babun"

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

if [ -r ~/.nvm  ]; then
  export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh"  ] && . "$NVM_DIR/nvm.sh"
fi

alias gst="git status"

alias aci="C:/Users/erick.romero/AppData/Roaming/nvm/v8.7.0/node.exe C:/Users/erick.romero/dev/jenkins-ci/index.js"

alias node8="C:/Users/erick.romero/AppData/Roaming/nvm/v8.7.0/node.exe"

alias tci="npm run test:ci"
alias tw="npm run test:watch"
alias t="npm run test"
alias sl="npm run start:local"
alias s="npm run start"
alias l="npm run lint"
alias lci="npm run lint:ci"
alias lf="npm run lint:fix"
alias vtp="cd ~/dev/amp-vtp"
alias vtps="cd ~/dev/amp-vtp/packages/amp-vtp-server"
alias vtpui="cd ~/dev/amp-vtp/packages/amp-vtp-ui"
alias pctest="npm run lint:ci && npm run test:ci && npm run build"
