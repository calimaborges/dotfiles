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
| `~/.config/zsh/journal.zsh` | `dot_config/zsh/journal.zsh` |
| `~/.config/atuin/config.toml` | `dot_config/atuin/config.toml` |
| `~/.config/wezterm/wezterm.lua` | `dot_config/wezterm/wezterm.lua` |
| `~/.config/nvim/init.lua` | `dot_config/nvim/init.lua` |
| `~/.config/nvim/plugin/gpg.lua` | `dot_config/nvim/plugin/gpg.lua` |
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

## Menu bar (macOS)

[Ice](https://icemenubar.app/) hides crowded menu bar icons behind a click. Keep the few you glance at often (Wi‑Fi, battery, clock) always visible and tuck the rest into the hidden section. Click the Ice chevron to expand when you need something.

System Settings → Control Center can also move occasional items out of the menu bar into Control Center. Prefer that for Bluetooth, AirDrop, and similar toggles; use Ice for third-party app icons.

## WezTerm sessions

WezTerm does the job tmux used to do. Each project gets its own session, a WezTerm workspace named `<context>/<project>` after its directory in `~/projects/<context>/<project>`. Every new tab in a session opens in that project's directory, wherever the current pane has moved to. Outside a project session, a new tab opens in the current pane's directory.

The tab bar is always visible and shows the current session's name in green on the right. Outside a project session it reads `default`.

| Shortcut | Action |
| --- | --- |
| Cmd+O (Super+O on Linux) | Fuzzy-find a project and switch to its session, creating the session if it is not open. Same key as `s-o` in Emacs |
| Cmd+J (Super+J on Linux) | Pick among the open sessions. Same key as `s-j` in Emacs |
| Ctrl+1 .. Ctrl+9 | Switch to an open session by number. Sessions are numbered in the order they were opened, so `default` is 1, and Cmd+J shows each number |
| Cmd+T or Ctrl+Shift+T | Open a tab in the session's project directory |

## Journal

The journal is one GPG-encrypted Markdown file per day, `YYYY-MM-DD.md.gpg`, in the git repository at `~/projects/personal/journal`. Run `journal-edit` in a terminal to write today's entry. It is the port of the Emacs command with the same name:

1. Pulls the journal repository. If the pull fails, it asks before opening, because an entry written on another computer may be missing.
2. Creates today's entry with a Markdown heading, encrypted to your default GPG key, unless the entry already exists.
3. Decrypts the entry once in the terminal, so the passphrase prompt appears before Neovim takes over the screen.
4. Opens Neovim with the most recent earlier entry on the left and today's entry on the right, with the cursor at the end of today's entry.

Neovim edits any `*.gpg` file in place. It decrypts the file into memory when it opens and encrypts it again on save, to the recipients the file already had, or to your default key for a new file. For these buffers it writes no swap file, no undo file, and no ShaDa file, so the plain text never reaches the disk. A file that cannot be decrypted opens empty and cannot be saved over.

`journal-edit` does not commit. Commit and push from Neovim with `<leader>gs` and `<leader>gp`.

## Set up a computer

1. Install chezmoi, WezTerm, Atuin (directory-aware shell history), mise (runtime and tool versions), Neovim, the tree-sitter CLI and a C compiler (nvim-treesitter builds its parsers with them), GnuPG (the journal is encrypted with it), and the font the WezTerm config uses.

   macOS, including Vicinae, Amethyst, and Ice:

   ```sh
   brew install chezmoi atuin mise neovim tree-sitter-cli gnupg pinentry-mac
   brew install --cask wezterm vicinae amethyst jordanbaird-ice font-fantasque-sans-mono-nerd-font
   ```

   Arch Linux:

   ```sh
   sudo pacman -S chezmoi wezterm atuin mise neovim tree-sitter-cli gnupg base-devel ttf-fantasque-nerd
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

4. On macOS, start Vicinae, Amethyst, and Ice.

   1. Open Vicinae and Amethyst and allow each one under System Settings > Privacy & Security > Accessibility. Open Ice and grant whatever it asks for (Screen Recording and/or Accessibility, depending on macOS version).
   2. Quit and reopen Amethyst. It does not manage windows until it is restarted with the permission in place.
   3. Add Amethyst and Ice under System Settings > General > Login Items. Vicinae registers itself.
   4. In Ice, drag icons you rarely need into the hidden section and leave Wi‑Fi, battery, and clock always visible.

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
