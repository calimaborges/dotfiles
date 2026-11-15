# dotfiles

My dotfiles for macOS and Linux, managed with [chezmoi](https://www.chezmoi.io).

chezmoi runs in symlink mode: each managed file in `$HOME` is a symlink into this repository, so editing either path edits the same file and programs such as WezTerm pick up the change on save.

## What is managed

| File in `$HOME` | File in this repository |
| --- | --- |
| `~/.config/wezterm/wezterm.lua` | `dot_config/wezterm/wezterm.lua` |

## Set up a computer

1. Install chezmoi, WezTerm, and the font the WezTerm config uses.

   macOS:

   ```sh
   brew install chezmoi
   brew install --cask wezterm font-fantasque-sans-mono-nerd-font
   ```

   Arch Linux:

   ```sh
   sudo pacman -S chezmoi wezterm ttf-fantasque-nerd
   ```

   Other Linux distributions: follow the install pages for [chezmoi](https://www.chezmoi.io/install/) and [WezTerm](https://wezterm.org/install/linux.html), then install FantasqueSansM from [Nerd Fonts](https://www.nerdfonts.com/font-downloads).

2. Clone this repository and link the dotfiles.

   On a new computer:

   ```sh
   chezmoi init --apply calimaborges
   ```

   On a computer that already has its own config files, review first. `chezmoi apply` replaces existing files without asking and without a backup:

   ```sh
   chezmoi init calimaborges
   chezmoi diff
   chezmoi apply
   ```

The repository is cloned over HTTPS into `~/.local/share/chezmoi`. To push changes from that computer, add `--ssh` to `chezmoi init` once the computer has a GitHub SSH key.

## Synchronize

Get the changes published from other computers:

```sh
chezmoi update
```

Publish the changes made on this computer:

```sh
chezmoi git add .
chezmoi git -- commit -m "Describe the change"
chezmoi git push
```

## Manage another file

```sh
chezmoi add ~/.config/example/example.conf
chezmoi apply
```

`chezmoi add` copies the file into this repository and `chezmoi apply` replaces the original with a symlink. Publish the change afterwards.

This repository is public, so never add files that contain secrets, keys, or tokens.
