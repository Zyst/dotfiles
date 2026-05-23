{ config, pkgs, ... }:

let
  dotfiles = "/home/zyst/dev/dotfiles";
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
      neovim
      ranger
      ripgrep
      termdown
      tmux
      tree
      xclip
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
      ".config/awesome" = {
        source = "${dotfiles}/awesome";
        recursive = true;
      };

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

      ".claude/skills/didactic-upstream-diff-iteration" = {
        source = "${dotfiles}/.claude/skills/didactic-upstream-diff-iteration";
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

      ".config/environment.d/10-shell.conf".text = ''
        SHELL=${config.home.homeDirectory}/.nix-profile/bin/fish
      '';

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

    sessionVariables = {
      LESS = "-FRX";
    };

    stateVersion = "22.05";
    username = "zyst";
    homeDirectory = "/home/zyst";
  };

  targets.genericLinux.enable = true;

  programs = {
    emacs.enable = true;

    fish = {
      enable = true;
      shellInit = ''
        if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        end
      '';
      interactiveShellInit = builtins.readFile "${dotfiles}/config.fish";
    };

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
          helper = [ "!gh auth git-credential" "libsecret" ];
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
        ui.default-command = "log";
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
