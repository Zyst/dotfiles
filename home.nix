{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
in
{
  home = {
    packages = (with pkgs; [
      bat
      clojure
      exa
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
      neovim
      ranger
      ripgrep
      termdown
      tmux
      tree
      xclip
      xdelta
      youtube-dl
      yt-dlp

      # Node 18
      nodejs-18_x
      nodePackages.eslint
      nodePackages.graphite-cli
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

      ".emacs.d" = {
        source = "${dotfiles}/.emacs.d";
        recursive = true;
      };

      ".config/openmw/settings.cfg".source = "${dotfiles}/openmw/settings.cfg";

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

    stateVersion = "22.05";
    username = "zyst";
    homeDirectory = "/home/zyst";
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

        credential.helper = "libsecret";
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

    mpv.enable = true;

    starship.enable = true;
  };
}
