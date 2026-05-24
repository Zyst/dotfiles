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
      git-quick-stats
      gtypist
      htop
      http-server
      jdk
      joker
      jq
      leiningen
      ncdu
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
    aerospace = {
      enable = true;
      launchd.enable = true;
      # Colemak-DH directionals m/n/e/i = west/south/north/east.
      settings = {
        start-at-login = true;

        # macOS keyboard layout is Colemak DH ANSI. AeroSpace's default qwerty
        # preset listens at QWERTY positions; the overrides below remap the
        # letters we use in bindings to the QWERTY positions Colemak-DH places
        # them at. Without this, alt-m, alt-n, alt-e, alt-i, alt-f, alt-t,
        # alt-shift-k, ctrl-cmd-r would all silently no-op.
        # Note: AeroSpace ships a `colemak` preset too, but standard Colemak
        # puts `m` in the bottom row while Colemak-DH keeps it on the home
        # row, so the preset alone doesn't fit — keep QWERTY preset and
        # override the specific keys we bind.
        key-mapping = {
          preset = "qwerty";
          key-notation-to-key-code = {
            # Home row right-hand: Colemak-DH m/n/e/i sit at QWERTY h/j/k/l
            m = "h";
            n = "j";
            e = "k";
            i = "l";
            # Other letters Colemak-DH relocates that we bind
            f = "e";
            t = "f";
            k = "n";
            r = "s";
          };
        };

        gaps = {
          inner.horizontal = 5;
          inner.vertical = 5;
          outer.left = 0;
          outer.bottom = 0;
          outer.top = 0;
          outer.right = 0;
        };

        mode.main.binding = {
          # Focus
          alt-m = "focus left";
          alt-n = "focus down";
          alt-e = "focus up";
          alt-i = "focus right";

          # Move (swap) — AeroSpace handles cross-monitor automatically
          alt-shift-m = "move left";
          alt-shift-n = "move down";
          alt-shift-e = "move up";
          alt-shift-i = "move right";

          # Switch to workspace (focus only)
          cmd-1 = "workspace 1";
          cmd-2 = "workspace 2";
          cmd-3 = "workspace 3";
          cmd-4 = "workspace 4";
          cmd-5 = "workspace 5";
          cmd-6 = "workspace 6";
          cmd-7 = "workspace 7";
          cmd-8 = "workspace 8";
          cmd-9 = "workspace 9";
          cmd-0 = "workspace 10";

          # Combined send-to-workspace + follow (matches skhdrc alt+cmd-N)
          alt-cmd-1 = [ "move-node-to-workspace 1" "workspace 1" ];
          alt-cmd-2 = [ "move-node-to-workspace 2" "workspace 2" ];
          alt-cmd-3 = [ "move-node-to-workspace 3" "workspace 3" ];
          alt-cmd-4 = [ "move-node-to-workspace 4" "workspace 4" ];
          alt-cmd-5 = [ "move-node-to-workspace 5" "workspace 5" ];
          alt-cmd-6 = [ "move-node-to-workspace 6" "workspace 6" ];
          alt-cmd-7 = [ "move-node-to-workspace 7" "workspace 7" ];
          alt-cmd-8 = [ "move-node-to-workspace 8" "workspace 8" ];
          alt-cmd-9 = [ "move-node-to-workspace 9" "workspace 9" ];
          alt-cmd-0 = [ "move-node-to-workspace 10" "workspace 10" ];

          # Layout toggles
          alt-f = "fullscreen";
          alt-shift-f = "layout floating tiling";
          alt-shift-t = "layout horizontal vertical";

          # Launchers — bypass `open -n` (which forks a new .app instance and
          # dock icon every press). Kitty's --single-instance daemon mode opens
          # new windows inside the existing process; AppleScript tells the
          # running Chrome to make a new window without spawning a new instance.
          alt-enter = "exec-and-forget /Applications/kitty.app/Contents/MacOS/kitty --single-instance --directory ~";
          alt-shift-enter = ''exec-and-forget osascript -e 'tell application "Google Chrome" to make new window' '';
          alt-shift-k = "exec-and-forget open $HOME";

          # Daemon
          ctrl-cmd-r = "reload-config";
        };
      };
    };

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

        credential = {
          helper = [ "osxkeychain" ];
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
