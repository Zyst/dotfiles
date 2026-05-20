# Recovery guide

Bootstrap a new machine to the point where `home-manager switch` can take over the rest of the setup:

- Install [Nix](https://nixos.org/download/) (follow the latest instructions on the site).
- Install [home-manager](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone) via `nix-shell` (the standalone install section has the current command).
- Clone this repo: `git clone https://github.com/Zyst/dotfiles ~/dev/dotfiles`.
- Symlink the right platform file into home-manager's config path, replacing the default `~/.config/home-manager/home.nix` it created on first install:
  - macOS: `ln -sf ~/dev/dotfiles/home-mac.nix ~/.config/home-manager/home.nix`
  - Linux: `ln -sf ~/dev/dotfiles/home.nix ~/.config/home-manager/home.nix`
  - WSL: `ln -sf ~/dev/dotfiles/home-wsl.nix ~/.config/home-manager/home.nix`
- Run `home-manager switch`.

After that, Claude or further manual edits can handle the rest. See `.claude/CLAUDE.md` for the full project context.
