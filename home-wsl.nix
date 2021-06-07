{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
in
{
  home = {
    packages = (with pkgs; [
      bat
      clojure
      ffmpeg
      fortune
      fzf
      git-quick-stats
      gtypist
      htop
      jdk
      joker
      jq
      leiningen
      ncdu
      neofetch
      ranger
      ripgrep
      termdown
      tmux
      tree
      xclip
      xdelta
      youtube-dl

      # Node
      # nodejs-10_x
      # nodejs-16_x
      nodejs
      nodePackages.eslint
      nodePackages.http-server
      nodePackages.neovim
      nodePackages.prettier
      nodePackages.typescript
      nodePackages.yarn
    ]);

    file = {
      ".vimrc".source = "${dotfiles}/.vimrc";

      ".bashrc".source = "${dotfiles}/bashrc";

      ".tmux.conf".source = "${dotfiles}/tmux.conf";

      ".eslintrc.js".source = "${dotfiles}/eslintrc.js";

      ".emacs.d" = {
        source = "${dotfiles}/.emacs.d";
        recursive = true;
      };

      ".config/nvim/init.vim".text =
        ''
        set nocompatible
        set runtimepath^=~/.vim runtimepath+=~/.vim/after
        let &packpath = &runtimepath
        source ~/.vimrc
        '';

      ".config/bat/config".text =
        ''
          --theme="base16"
        '';
    };

    extraOutputsToInstall = [ "man" ];
  };

  programs = {
    emacs.enable = true;

    git = {
      enable = true;
      userName = "Erick Romero";
      userEmail = "erick.romero.dev@gmail.com";
      extraConfig = {
        core = {
          editor = "nvim";
        };

        credential.helper = "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe";
      };

      delta = {
        enable = true;

        options = {
          syntax-theme = "base16";
        };
      };
    };

    home-manager.enable = true;

    man.enable = true;
  };
}
