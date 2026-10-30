{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  home = {
    homeDirectory = "/home/zyst";

    packages = (with pkgs; [
      gcc
      gnumake
      typescript
      unzip
      wl-clipboard
      xclip
    ]);
  };

  targets.genericLinux.enable = true;
}
