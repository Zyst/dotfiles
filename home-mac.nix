{ config, pkgs, ... }:

let
  dotfiles = "/Users/zyst/dev/dotfiles";
in
{
  home = {
    packages = (with pkgs; [
      bat
      clojure
      eslint
      eza
      fastfetch
      ffmpeg
      fortune
      fzf
      gh
      git-quick-stats
      gtypist
      htop
      http-server
      jdk
      joker
      jq
      leiningen
      ncdu
      neovim
      neovim-node-client
      nodejs_22
      prettier
      ranger
      ripgrep
      termdown
      tmux
      tree
      xdelta
      yarn
      yt-dlp
    ]);

    file = {
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
    homeDirectory = "/Users/zyst";
  };

  news.display = "silent";

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
        ui.default-command = "log";

        # When `jj describe` opens the editor, include the full git-style diff
        # below a `JJ: ignore-rest` marker (jj's equivalent of git commit -v's
        # `>8` cut line). Everything past the marker is stripped on save, so
        # the diff is read-only context, not part of the description.
        templates.draft_commit_description = ''
          concat(
            coalesce(description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.summary()),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
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
