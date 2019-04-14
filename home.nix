{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
in
{
  home = {
    packages = [
      pkgs.bat
      pkgs.fortune
      pkgs.neofetch
      pkgs.ripgrep
    ];

    file = {
      ".config/nvim/init.vim".text =
      ''
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath = &runtimepath
      source ~/.vimrc
      '';

      ".vimrc".source = "${dotfiles}/.vimrc";

      ".bashrc".source = "${dotfiles}/bashrc";

      ".tmux.conf".source = "${dotfiles}/tmux.conf";

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

    git = {
      enable = true;
      userName = "Erick Romero";
      userEmail = "erick.romero.dev@gmail.com";
      extraConfig.core.editor = "nvim";
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
