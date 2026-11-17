# dotfiles

My dotfiles for macOS and Linux, managed with [chezmoi](https://www.chezmoi.io).

chezmoi runs in symlink mode: each managed file in `$HOME` is a symlink into this repository, so editing either path edits the same file and programs such as WezTerm pick up the change on save.

## What is managed

| File in `$HOME` | File in this repository |
| --- | --- |
| `~/.zshenv` | `dot_zshenv` |
| `~/.config/zsh/.zshrc` | `dot_config/zsh/dot_zshrc` |
| `~/.config/zsh/.zprofile` | `dot_config/zsh/dot_zprofile` |
| `~/.config/zsh/aliases.zsh` | `dot_config/zsh/aliases.zsh` |
| `~/.config/zsh/git.zsh` | `dot_config/zsh/git.zsh` |
| `~/.config/atuin/config.toml` | `dot_config/atuin/config.toml` |
| `~/.config/wezterm/wezterm.lua` | `dot_config/wezterm/wezterm.lua` |
| `~/.config/nvim/init.lua` | `dot_config/nvim/init.lua` |
| `~/.config/vicinae/shared.json` | `dot_config/vicinae/shared.json` |
| `~/.config/amethyst/amethyst.yml` (macOS only) | `dot_config/amethyst/amethyst.yml` |

Zsh config lives under `~/.config/zsh` via `ZDOTDIR`. The only zsh file that must stay in `$HOME` is `~/.zshenv`, which sets `ZDOTDIR` before the rest of the startup files load. After apply, remove any leftover `~/.zshrc` and the old `~/.config/zsh` → neoarch symlink if they still exist.

Git config is not managed here yet. Keep `~/.config/git` on each machine until that is set up later.

## Keyboard workflow

One window is visible at a time, it fills the screen, and a shortcut brings each app to the front.

| Shortcut | Action | Handled by |
| --- | --- | --- |
| Alt+1 | Focus WezTerm, launching it if it is not running | Vicinae |
| Alt+2 | Focus Zen Browser, launching it if it is not running | Vicinae |
| Alt+3 | Focus Cursor, launching it if it is not running | Vicinae |
| Alt+Space | Open the Vicinae launcher | Vicinae |
| Alt+Shift+J / Alt+Shift+K | Cycle through the windows on the screen | Amethyst |

On macOS, [Vicinae](https://docs.vicinae.com) owns the app shortcuts and [Amethyst](https://ianyh.com/amethyst/) keeps every window at full screen size with its `fullscreen` layout. The app shortcuts are set up for macOS only so far.

To give another app a shortcut, add its entry to `dot_config/vicinae/shared.json`. Vicinae reloads the file on save. List the app IDs with:

```sh
vicinae cmd ls | grep applications
```

Vicinae rewrites `~/.config/vicinae/settings.json` whenever a setting changes in its window, and in doing so replaces a symlink with a regular file. For that reason chezmoi only creates `settings.json` once, with an import of `shared.json`, and never touches it again. Settings changed in the Vicinae window stay on that computer; settings meant for every computer go in `shared.json`.

## Set up a computer

1. Install chezmoi, WezTerm, Atuin (directory-aware shell history), mise (runtime and tool versions), Neovim, the tree-sitter CLI and a C compiler (nvim-treesitter builds its parsers with them), and the font the WezTerm config uses.

   macOS, including Vicinae and Amethyst:

   ```sh
   brew install chezmoi atuin mise neovim tree-sitter-cli
   brew install --cask wezterm vicinae amethyst font-fantasque-sans-mono-nerd-font
   ```

   Arch Linux:

   ```sh
   sudo pacman -S chezmoi wezterm atuin mise neovim tree-sitter-cli base-devel ttf-fantasque-nerd
   ```

   Other Linux distributions: follow the install pages for [chezmoi](https://www.chezmoi.io/install/), [WezTerm](https://wezterm.org/install/linux.html), and [mise](https://mise.jdx.dev/installing-mise.html), then install FantasqueSansM from [Nerd Fonts](https://www.nerdfonts.com/font-downloads).

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

   New zsh sessions run `mise activate`. Install the tools from your mise config, then start a new shell:

   ```sh
   mise install
   exec zsh
   ```

3. On macOS, start the Atuin daemon so history search stays fast:

   ```sh
   brew services start atuin
   ```

   On Linux, enable the packaged Atuin service if your distribution provides one, or run `atuin daemon start`.

   Optional: import an existing shell history once, then start a new shell:

   ```sh
   atuin import zsh
   exec zsh
   ```

   Atuin records history and owns Ctrl-R (compact search: workspace → directory → global → session). Up arrow stays on normal zsh history so it cycles one command at a time. Enter pastes the selected command for editing before you run it.

4. On macOS, start Vicinae and Amethyst.

   1. Open both apps and allow each one under System Settings > Privacy & Security > Accessibility.
   2. Quit and reopen Amethyst. It does not manage windows until it is restarted with the permission in place.
   3. Add Amethyst under System Settings > General > Login Items. Vicinae registers itself.

   If Vicinae was opened before step 2, `~/.config/vicinae/settings.json` already exists and chezmoi leaves it alone. Add the import by hand:

   ```json
   "imports": ["./shared.json"]
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
