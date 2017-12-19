# Color stuff!
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h\033[m\]:\[\033[35m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Can't use $USER in git bash apparently
username=$(whoami)

# Default ls I enjoy more
alias ls='ls -GFh'

# go things
export GOPATH=$HOME/.go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# GRC go test
alias go="grc go"

# Turn off Display (OS X)
alias sleep="pmset displaysleepnow"

alias gst="git status"
alias glg="git log --oneline --decorate --graph"

alias aci="C:/Users/$username/AppData/Roaming/nvm/v8.9.1/node64.exe C:/Users/$username/dev/amp-vtp-tools/jenkins-ci/index.js"

alias tci="npm run test:ci"
alias tw="npm run test:watch"
alias t="npm run test"
# alias sl="npm run start:local"
alias sl="./start.sh development"
alias s="npm run start"
alias l="npm run lint"
alias lci="npm run lint:ci"
alias lf="npm run lint:fix"
alias vtp="cd ~/dev/amp-vtp"
alias vtps="cd ~/dev/amp-vtp/packages/amp-vtp-server"
alias vtpui="cd ~/dev/amp-vtp/packages/amp-vtp-ui"
alias pctest="npm run lint:ci && npm run test:ci && npm run build"
