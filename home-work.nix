{ config, pkgs, ... }:

let
  dotfiles = "/home/erick.romero/dev/dotfiles";
in
{
  home = {
    packages = [
      pkgs.bat
      pkgs.fortune
      pkgs.fzf
      pkgs.htop
      pkgs.neofetch
      pkgs.ranger
      pkgs.ripgrep
      pkgs.tmux
      pkgs.tree

      # Node 6
      # pkgs.nodejs-6_x

      # Node 8
      # pkgs.nodejs-8_x

      # Node 10
      pkgs.nodejs-10_x
      pkgs.nodePackages.eslint
      pkgs.nodePackages.http-server
      pkgs.nodePackages.prettier
    ];

    file = {
      ".config/nvim/init.vim".text =
      ''
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath = &runtimepath
      source ~/.vimrc
      '';

      ".config/alacritty/alacritty.yml".source = "${dotfiles}/alacritty.yml";

      ".config/regolith/i3/config".source = "${dotfiles}/regolith-config";

      ".vimrc".source = "${dotfiles}/.vimrc";

      ".bashrc".source = "${dotfiles}/bashrc";

      ".tmux.conf".source = "${dotfiles}/tmux.conf";

      ".eslintrc.js".source = "${dotfiles}/eslintrc.js";

      ".emacs.d" = {
        source = "${dotfiles}/.emacs.d";
        recursive = true;
      };
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };

    neovim = {
      enable = true;
      vimAlias = true;
    };

    emacs = {
      enable = true;
    };
  };
}
