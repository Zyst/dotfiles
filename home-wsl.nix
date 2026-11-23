{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  home = {
    homeDirectory = "/home/zyst";

    packages = (with pkgs; [
      gcc
      gnumake
      (noto-fonts.override { variants = [ "NotoSansSymbols" "NotoSansSymbols2" ]; })
      typescript
      unzip
      wl-clipboard
      xclip
    ]);
  };

  fonts.fontconfig.enable = true;

  targets.genericLinux.enable = true;
}
