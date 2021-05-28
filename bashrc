# Color stuff!
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h\033[m\]:\[\033[35m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Can't use $USER in git bash apparently
username=$(whoami)

# Default ls I enjoy more
alias ls='ls -GFh'

# GRC go test
# alias go="grc go"

# Turn off Display (OS X)
alias sleep="pmset displaysleepnow"

alias emacs="emacs -nw -a \"\""
alias em="emacs -nw -a \"\""

alias gst="git status"
alias glg="git log --oneline --decorate --graph"
alias gw="git log --follow -p --"

alias rgg="rg --files -g"

alias tci="npm run test:ci"
alias tw="npm run test:watch"
alias t="npm run test"
alias sl="npm run start:local"
alias s="npm run start"
alias l="npm run lint"
alias lci="npm run lint:ci"
alias lf="npm run lint:fix"
alias dot="cd ~/dev/dotfiles"

alias gcm="git checkout master --"

alias dotall="dotnet.exe restore && dotnet.exe build && dotnet.exe msbuild && dotnet.exe run"

# Game
alias tron="ssh sshtron.zachlatta.com"

alias ni="npm install && npm prune"

alias hms="cp ~/dev/dotfiles/home.nix ~/.config/nixpkgs/home.nix &&
  home-manager switch"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--layout=reverse --height 40%'

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

export NODE_OPTIONS=--max-old-space-size=4096
