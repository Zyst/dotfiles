# Color stuff!
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls -GFh'

# go things
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# GRC go test
alias go="grc go"

# Turn off Display
alias sleep="pmset displaysleepnow"

alias aci="C:/Users/erick.romero/AppData/Roaming/nvm/v8.7.0/node.exe C:/Users/erick.romero/Programming/jenkins-ci/index.js"

alias node8="C:/Users/erick.romero/AppData/Roaming/nvm/v8.7.0/node.exe"

alias tci="npm run test:ci"
alias tw="npm run test:watch"
alias t="npm run test"
alias sl="npm run start:local"
alias s="npm run start"
alias l="npm run lint"
alias lci="npm run lint:ci"
alias lf="npm run lint:fix"
alias vtp="cd ~/Programming/amp-vtp"
alias vtps="cd ~/Programming/amp-vtp/packages/amp-vtp-server"
alias vtpui="cd ~/Programming/amp-vtp/packages/amp-vtp-ui"
