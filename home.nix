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
      htop
      neofetch
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
      nodePackages.prettier
    ]);

    file = {
      ".config/awesome" = {
        source = "${dotfiles}/awesome";
        recursive = true;
      };

      ".config/fish/config.fish".text =
      ''
      set fish_greeting

      starship init fish | source
      '';

      ".config/kitty/kitty.conf".source = "${dotfiles}/kitty.conf";

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

      ".xinitrc".text = "exec awesome";
    };

    extraOutputsToInstall = [ "man" ];
  };

  programs = {
    emacs.enable = true;

    git = {
      enable = true;
      userName = "Erick Romero";
      userEmail = "erick.romero@bouncex.com";
      extraConfig.core.editor = "nvim";
    };

    home-manager.enable = true;

    neovim = {
      enable = true;
      vimAlias = true;
    };

    man.enable = true;

    mpv.enable = true;

    starship.enable = true;
  };
}
