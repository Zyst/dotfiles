{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
in
{
  home = {
    packages = (with pkgs; [
      bat
      fortune
      fzf
      git-quick-stats
      gtypist
      htop
      jdk14
      jq
      ncdu
      neofetch
      neovim-nightly
      ranger
      ripgrep
      tmux
      tree
      xclip
      youtube-dl

      # Node 12
      nodejs-12_x
      nodePackages.eslint
      nodePackages.http-server
      nodePackages.neovim
      nodePackages.prettier
      nodePackages.yarn
    ]);

    file = {
      ".config/awesome" = {
        source = "${dotfiles}/awesome";
        recursive = true;
      };

      ".config/fish/config.fish".text =
      ''
      set fish_greeting

      alias work="sudo python3 /home/zyst/dev/get-shit-done/get-shit-done.py work"
      alias play="sudo python3 /home/zyst/dev/get-shit-done/get-shit-done.py play"

      alias vim="nvim"

      function 2fa
        cat /home/zyst/.2fa/$argv | xargs -I {} oathtool --base32 --totp "{}"
        cat /home/zyst/.2fa/$argv | xargs -I {} oathtool --base32 --totp "{}" | xclip -sel clip
      end

      starship init fish | source
      '';

      ".config/kitty/kitty.conf".source = "${dotfiles}/kitty.conf";

      ".config/nvim/init.vim".text =
      ''
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath = &runtimepath
      source ~/.vimrc
      '';

      ".config/mpv" = {
        source = "${dotfiles}/mpv";
        recursive = true;
      };

      ".config/espanso" = {
        source = "${dotfiles}/espanso";
        recursive = true;
      };

      ".config/nixpkgs/overlays" = {
        source = "${dotfiles}/nix-overlays";
        recursive = true;
      };

      ".vimrc".source = "${dotfiles}/.vimrc";

      ".bashrc".source = "${dotfiles}/bashrc";

      ".tmux.conf".source = "${dotfiles}/tmux.conf";

      ".eslintrc.js".source = "${dotfiles}/eslintrc.js";

      ".emacs.d" = {
        source = "${dotfiles}/.emacs.d";
        recursive = true;
      };

      ".xinitrc".text = "exec awesome";

      ".config/regolith/Xresources".source = "${dotfiles}/Xresources-regolith";
      ".config/regolith/i3/config".source = "${dotfiles}/i3.config";
    };

    extraOutputsToInstall = [ "man" ];
  };

  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs26;
    };

    git = {
      enable = true;
      userName = "Erick Romero";
      userEmail = "erick.romero.dev@gmail.com";
      extraConfig.core.editor = "nvim";
    };

    home-manager.enable = true;

    man.enable = true;

    mpv.enable = true;

    starship.enable = true;
  };
}
