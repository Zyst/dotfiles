{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dev/dotfiles";
in
{
  imports = [ ./common.nix ];

  home = {
    homeDirectory = "/home/zyst";

    packages = (with pkgs; [
      wl-clipboard
      xclip
    ]);

    file = {
      ".config/awesome" = {
        source = "${dotfiles}/awesome";
        recursive = true;
      };

      ".config/environment.d/10-shell.conf".text = ''
        SHELL=${config.home.homeDirectory}/.nix-profile/bin/fish
      '';

      ".xinitrc".text = "exec awesome";

      ".config/regolith/Xresources".source = "${dotfiles}/Xresources-regolith";
      ".config/regolith/i3/config".source = "${dotfiles}/i3.config";
    };
  };

  targets.genericLinux.enable = true;

  programs.git.settings.credential.helper = [ "libsecret" ];
}
