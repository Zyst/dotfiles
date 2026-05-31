{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dev/dotfiles";
in
{
  home = {
    packages = (with pkgs; [
      bat
      cargo
      clojure
      eslint
      eslint_d
      eza
      fastfetch
      ffmpeg
      fortune
      git-quick-stats
      go
      gtypist
      htop
      http-server
      jdk
      joker
      jq
      leiningen
      luarocks
      ncdu
      nixd
      nodejs_22
      noti
      prettier
      ranger
      ripgrep
      rustc
      termdown
      tmux
      tree
      tree-sitter
      wget
      xdelta
      yarn
      yt-dlp
    ]);

    file = {
      ".config/kitty/kitty.conf".source = "${dotfiles}/kitty.conf";

      ".config/kitty/kitty-themes" = {
        source = "${dotfiles}/kitty-themes";
        recursive = true;
      };

      ".claude/themes/high-contrast-badge.json".source = "${dotfiles}/claude-themes/high-contrast-badge.json";

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

    fzf = {
      enable = true;
      enableFishIntegration = true;
      historyWidgetOptions = [
        "--delimiter=\\t"
        "--with-nth=3.."
        "--nth=3..,.."
      ];
    };

    gh = {
      enable = true;
      settings.aliases.co = "pr checkout";
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

    neovim = {
      enable = true;
      withNodeJs = true;
      withPython3 = false;
      withRuby = false;
      # Sourced at runtime via ~/.config/nvim/init.lua
      extraConfig = ''
        set nocompatible
        set runtimepath^=~/.vim runtimepath+=~/.vim/after
        let &packpath = &runtimepath
        source ~/.vimrc
      '';
    };

    starship.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
