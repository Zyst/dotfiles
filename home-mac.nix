{ config, pkgs, ... }:

let
  dotfiles = "/Users/zyst/dev/dotfiles";
in
{
  home = {
    packages = (with pkgs; [
      bat
      clojure
      eza
      ffmpeg
      fortune
      fzf
      gh
      git-quick-stats
      gtypist
      htop
      jdk
      joker
      jq
      leiningen
      ncdu
      fastfetch
      fish
      neovim
      ranger
      ripgrep
      termdown
      tmux
      tree
      xdelta
      yt-dlp

      # Node 22
      nodejs_22
      eslint
      http-server
      neovim-node-client
      prettier
      yarn
    ]);

    file = {
      ".config/fish/config.fish".source = "${dotfiles}/config.fish";

      ".config/kitty/kitty.conf".source = "${dotfiles}/kitty.conf";

      ".config/ranger/rc.conf".source = "${dotfiles}/ranger/rc.conf";

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
    homeDirectory = "/Users/zyst";
  };

  programs = {
    emacs.enable = true;

    git = {
      enable = true;
      settings = {
        user = {
          name = "Erick Romero";
          email = "erick.romero.dev@gmail.com";
        };

        core = {
          editor = "nvim";
        };

        credential = {
          helper = [ "!gh auth git-credential" "osxkeychain" ];
        };
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Erick Romero";
          email = "erick.romero.dev@gmail.com";
        };
        ui.editor = "nvim";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;

      options = {
        syntax-theme = "base16";
      };
    };

    home-manager.enable = true;

    man.enable = true;

    mpv.enable = true;

    starship.enable = true;
  };
}
