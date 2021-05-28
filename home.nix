{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
in
{
  home = {
    packages = (with pkgs; [
      bat
      clojure
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

      # Node 16
      nodejs-16_x
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

      ".config/fish/config.fish".source = "${dotfiles}/config.fish";

      ".config/kitty/kitty.conf".source = "${dotfiles}/kitty.conf";

      ".config/mpv" = {
        source = "${dotfiles}/mpv";
        recursive = true;
      };

      ".config/espanso" = {
        source = "${dotfiles}/espanso";
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
      extraConfig.core.editor = "nvim";

      delta = {
        enable = true;

        options = {
          syntax-theme = "base16";
        };
      };
    };

    home-manager.enable = true;

    man.enable = true;

    mpv.enable = true;

    starship.enable = true;
  };
}
