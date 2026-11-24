# Recovery guide

Bootstrap a new machine to the point where `home-manager switch` can take over the rest of the setup:

- Install [Nix](https://nixos.org/download/) (follow the latest instructions on the site).
- Install [home-manager](https://nix-community.github.io/home-manager/installation/standalone.html#sec-install-standalone) via `nix-shell`. Use matching Nixpkgs and Home Manager release channels; the standalone install section has the current commands.
- Clone this repo: `git clone https://github.com/Zyst/dotfiles ~/dev/dotfiles`.
- Symlink the right platform file into home-manager's config path, replacing the default `~/.config/home-manager/home.nix` it created on first install:
  - macOS: `ln -sf ~/dev/dotfiles/home-mac.nix ~/.config/home-manager/home.nix`
  - Linux: `ln -sf ~/dev/dotfiles/home.nix ~/.config/home-manager/home.nix`
  - WSL: `ln -sf ~/dev/dotfiles/home-wsl.nix ~/.config/home-manager/home.nix`
- Run `home-manager switch`. On first activation, use `home-manager switch -b pre-home-manager` to back up existing files that would conflict with managed files.

After that, an agent or further manual edits can handle the rest. See [AGENTS.md](AGENTS.md) for shared project instructions, `.agents/` for notes, TODOs, and audits, and `.claude/` for Claude-specific instructions, skills, and settings.
