{ config, pkgs, ... }:

{
  imports = [ ./common.nix ];

  home = {
    homeDirectory = "/Users/zyst";

    packages = (with pkgs; [
      caffeine
    ]);

    file = {
      # Surface nix-installed Caffeine.app under ~/Applications so Spotlight /
      # Launchpad find it. The bare nix-profile install lands at
      # ~/.nix-profile/Applications/, which macOS doesn't index.
      "Applications/Caffeine.app".source = "${pkgs.caffeine}/Applications/Caffeine.app";
    };
  };

  programs = {
    git.settings.credential.helper = [ "osxkeychain" ];

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
  };
}
