set fish_greeting

alias clrepl="clojure -Sdeps '{:deps {nrepl {:mvn/version \"0.7.0\"} cider/cider-nrepl {:mvn/version \"0.25.0\"}}}' -m nrepl.cmdline --middleware '[\"cider.nrepl/cider-middleware\"]'"
alias ls="exa --tree --level=1"
alias juiceme="adb shell ls /sdcard/Oculus/VideoShots/ | sort -r | head -n1 | xargs -I '{}' adb pull /sdcard/Oculus/VideoShots/'{}'"
alias re="watch -n 1 -g '$1'"
alias gst="git status"
alias glg="git log --oneline --decorate --graph"
alias rgg="rg --files -g"
alias nz="nvim ~/.zshrc"

function 2fa
  cat /home/zyst/.2fa/$argv | xargs -I {} oathtool --base32 --totp "{}"
  cat /home/zyst/.2fa/$argv | xargs -I {} oathtool --base32 --totp "{}" | xclip -sel clip
end

set -gx FZF_DEFAULT_COMMAND "rg --files --hidden --follow --glob '!.git'"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_DEFAULT_OPTS "--layout=reverse --height 40%"
set -gx EDITOR "nvim"

status --is-interactive; and source (rbenv init -|psub)

starship init fish | source
