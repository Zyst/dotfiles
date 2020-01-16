{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
in
{
  home = {
    packages = [
      pkgs.bat
      pkgs.fortune
      pkgs.fzf
      pkgs.git-quick-stats
      pkgs.htop
      pkgs.neofetch
      pkgs.ranger
      pkgs.ripgrep
      pkgs.tmux
      pkgs.tree
      pkgs.xclip
      pkgs.youtube-dl

      # Node 12
      pkgs.nodejs-12_x
      pkgs.nodePackages.eslint
      pkgs.nodePackages.http-server
      pkgs.nodePackages.prettier
    ];

    file = {
      ".config/awesome" = {
        source = "${dotfiles}/awesome";
        recursive = true;
      };

      ".config/nvim/init.vim".text =
      ''
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath = &runtimepath
      source ~/.vimrc
      '';

      ".vimrc".source = "${dotfiles}/.vimrc";

      ".bashrc".source = "${dotfiles}/bashrc";

      ".tmux.conf".source = "${dotfiles}/tmux.conf";

      ".eslintrc.js".source = "${dotfiles}/eslintrc.js";

      ".emacs.d" = {
        source = "${dotfiles}/.emacs.d";
        recursive = true;
      };

      ".xsession".text = "exec awesome";
    };

    extraOutputsToInstall = [ "man" ];
  };

  programs = {
    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "Erick Romero";
      userEmail = "erick.romero@bouncex.com";
      extraConfig.core.editor = "nvim";
    };

    neovim = {
      enable = true;
      vimAlias = true;
    };

    emacs = {
      enable = true;
    };

    mpv = {
      enable = true;
    };

    man = {
      enable = false;
    };
  };
}
