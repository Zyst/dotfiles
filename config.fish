set fish_greeting

alias clrepl="clojure -Sdeps '{:deps {nrepl {:mvn/version \"0.7.0\"} cider/cider-nrepl {:mvn/version \"0.25.0\"}}}' -m nrepl.cmdline --middleware '[\"cider.nrepl/cider-middleware\"]'"

function 2fa
  cat /home/zyst/.2fa/$argv | xargs -I {} oathtool --base32 --totp "{}"
  cat /home/zyst/.2fa/$argv | xargs -I {} oathtool --base32 --totp "{}" | xclip -sel clip
end

starship init fish | source
