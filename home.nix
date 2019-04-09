{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
in
{
  home = {
    packages = [
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

      ".config/nixpkgs/home.nix".source = "${dotfiles}/home.nix";
      
      ".vimrc".source = "${dotfiles}/vimrc";

      ".bashrc".source = "${dotfiles}/bashrc";

      ".tmux.conf".source = "${dotfiles}/tmux.conf";
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
    };

    neovim = {
      enable = true;
    };

    emacs = {
      enable = true;
    };
  };
}
