# dotfiles

My dotfiles for macOS and Linux, managed with [chezmoi](https://www.chezmoi.io) in symlink mode: each managed file in `$HOME` is a symlink into this repository, so editing either path edits the same file. A leading `dot_` here is a leading `.` in `$HOME`: `dot_config/zsh/dot_zshrc` is `~/.config/zsh/.zshrc`.

This repository is public. Never add files that contain secrets, keys, or tokens.

## New computer

1. Install the packages. WezTerm must be there before step 2, which copies its terminfo on macOS. Ardia is not in these lists; install it separately.

   ```sh
   # macOS
   brew install chezmoi mcfly mise neovim tree-sitter-cli gnupg pinentry-mac
   brew install --cask wezterm vicinae amethyst thaw font-fantasque-sans-mono-nerd-font
   ```

   ```sh
   # Arch Linux
   sudo pacman -S chezmoi wezterm mcfly mise neovim tree-sitter-cli gnupg base-devel ttf-fantasque-nerd
   ```

   Other Linux distributions: follow the install pages for [chezmoi](https://www.chezmoi.io/install/), [WezTerm](https://wezterm.org/install/linux.html), and [mise](https://mise.jdx.dev/installing-mise.html), then install FantasqueSansM from [Nerd Fonts](https://www.nerdfonts.com/font-downloads).

2. Clone this repository and link the files. Add `--ssh` to clone over SSH instead of HTTPS, which needs a GitHub SSH key on the computer and lets it push.

   ```sh
   chezmoi init --apply calimaborges
   ```

   On a computer that already has config files, review first. `chezmoi apply` replaces existing files without asking and without a backup:

   ```sh
   chezmoi init calimaborges
   chezmoi diff
   chezmoi apply
   ```

3. **Zsh and mise.** Install the tools from the managed mise config, then start a new shell:

   ```sh
   mise install
   exec zsh
   ```

4. **Neovim.** Run `nvim` once. It installs the plugins at the revisions in `nvim-pack-lock.json` and builds the Tree-sitter parsers.

5. **Vicinae, Amethyst, and Thaw** (macOS). Allow Vicinae and Amethyst under System Settings > Privacy & Security > Accessibility. Open Thaw and grant Accessibility, then Menu Bar Layout Access when it asks; Screen Recording is optional. Quit and reopen Amethyst, which manages no windows until it restarts with the permission. Add Amethyst and Thaw under System Settings > General > Login Items. Vicinae registers itself.

6. **Ardia.** Open Ardia, then write the schema files and create the profiles. Afterwards, set the password managers and the control settings by hand, as [Ardia](#ardia) explains. Install Floccus for every profile:

   ```sh
   ardia config init
   sync-ardia-profiles
   sync-ardia-extensions
   ```

   Quit and reopen Ardia after `sync-ardia-extensions`. If Floccus is still missing, run `sync-ardia-extensions --web-store` and click Add on each Web Store tab.

7. **Journal.** Import your GPG secret key and clone the journal repository into `~/projects/personal/journal`.

8. **Git.** Git config is not managed here yet. Set up `~/.config/git` by hand.

## Sync

### Pull

```sh
chezmoi update
```

This pulls the repository and applies it. WezTerm, Vicinae, and Ardia's `config.json` reload on their own. The other apps need one more step when their files changed:

| App | After the pull |
| --- | --- |
| Zsh | `exec zsh` |
| mise | If `config.toml` changed, run `mise install` |
| Neovim | Restart it. If `nvim-pack-lock.json` changed, run `:lua vim.pack.update(nil, { target = "lockfile" })` and confirm with `:write` |
| Ardia | If `profiles.json` changed, run `sync-ardia-profiles` while Ardia is running. For Floccus on new machines or profiles, run `sync-ardia-extensions`, then quit and reopen Ardia |
| Amethyst | Relaunch it |

### Push

Edits to managed files are already in the repository, because the files in `$HOME` are symlinks. These changes need a step before the commit:

| Change | Before the commit |
| --- | --- |
| A file chezmoi does not manage yet | `chezmoi add ~/.config/example/example.conf`, then `chezmoi apply` to replace the original with a symlink |
| mise tools or settings | `mise use -g …` or `mise settings set …`, which rewrite `config.toml` |
| Neovim plugin versions | `:lua vim.pack.update()` and `:write`, which rewrite `nvim-pack-lock.json` |
| Ardia setting | `ardia config set KEY VALUE`, then `ardia config check` |
| Ardia profile | Edit `profiles.json`, then run `sync-ardia-profiles` |
| Ardia Floccus | Run `sync-ardia-extensions`, then quit and reopen Ardia |
| Vicinae setting | Put it in `shared.json`. A setting changed in the Vicinae window stays on that computer |

```sh
chezmoi git add .
chezmoi git -- commit -m "Describe the change"
chezmoi git push
```

## Zsh

Files: `~/.zshenv` and, in `~/.config/zsh`, `.zshrc`, `.zprofile`, `aliases.zsh`, `git.zsh`, and `journal.zsh`.

`~/.zshenv` sets `ZDOTDIR`, so every other zsh file lives in `~/.config/zsh`. `.zprofile` puts Homebrew and `~/.local/bin` on `PATH`. `.zshrc` activates mise and McFly when they are installed. History is large, shared across sessions, and deduplicated. Up arrow stays on normal zsh history; Ctrl-R opens McFly, which ranks by directory, recency, and exit status.

On a computer that had the old setup, after the first apply remove any leftover `~/.zshrc` and the old `~/.config/zsh` → neoarch symlink if they still exist. If Atuin was installed before, uninstall it (`brew uninstall atuin` or the distro equivalent) and remove `~/.local/share/atuin` if you no longer want its database.

## McFly

No managed config file. McFly imports `~/.zsh_history` on first run and keeps its SQLite database under `~/Library/Application Support/McFly` on macOS or `~/.local/share/mcfly` on Linux. It still writes normal zsh history, so you can stop using it without losing the file.

## mise

Files: `~/.config/mise/config.toml`.

Global tools and settings live here. Project tools stay in each project's `mise.toml`. Keep machine-only overrides in an unmanaged `config.local.toml` beside it. Installs, plugins, and shims stay in `~/.local/share/mise` and are not managed.

`mise use -g` and `mise settings` write through the symlink. After a pull that changes tools, run `mise install`.

## WezTerm

Files: `~/.config/wezterm/wezterm.lua`. WezTerm reloads it on save.

The config sets `TERM` to `wezterm`. On macOS, every `chezmoi apply` copies WezTerm's terminfo into `~/.terminfo`. On Linux, check that `infocmp wezterm` finds it.

WezTerm does the job tmux used to do. Each project in `~/projects/<context>/<project>` gets its own session, a workspace named `<context>/<project>`, whose new tabs open in the project's directory. The tab bar appears with a second tab and shows the session's name on the right, or `default` outside a project session.

| Shortcut | Action |
| --- | --- |
| Cmd+O (Super+O on Linux) | Fuzzy-find a project and switch to its session, creating it if it is not open |
| Cmd+J (Super+J on Linux) | Pick among the open sessions |
| Ctrl+1 .. Ctrl+9 | Switch to an open session by number, in the order they were opened. `default` is 1, and Cmd+J shows each number |
| Cmd+T or Ctrl+Shift+T | Open a tab in the session's project directory |

## Neovim

Files in `~/.config/nvim`: `init.lua`, `plugin/gpg.lua`, `after/ftplugin/markdown.lua`, and `nvim-pack-lock.json`.

The built-in `vim.pack` installs the plugins and pins their revisions in `nvim-pack-lock.json`. A plugin removed from `init.lua` on one computer stays installed on the others until you run `:lua vim.pack.del({ "name" })` there.

`plugin/gpg.lua` decrypts any `*.gpg` file into memory when it opens and encrypts it again on save, to the recipients the file already had or to your default key. These buffers get no swap, undo, or ShaDa file, so the plain text never reaches the disk. A file that cannot be decrypted opens empty and cannot be saved over.

## Journal

Files: `~/.config/zsh/journal.zsh`. It needs GnuPG and the Neovim config.

The journal is one GPG-encrypted Markdown file per day, `YYYY-MM-DD.md.gpg`, in the git repository at `~/projects/personal/journal`. `journal-edit` pulls that repository, creates today's entry encrypted to your default key, decrypts it once so the passphrase prompt comes before Neovim, and opens it beside the most recent earlier entry. If the pull fails, it asks before opening, because an entry written on another computer may be missing.

`journal-edit` does not commit. Commit and push from Neovim with `<leader>gs` and `<leader>gp`.

## VPN

File: `~/.local/bin/vpn`. It needs `pass`, GnuPG, and [snx-rs](https://github.com/ancwrd1/snx-rs) (`snxctl` on `PATH`).

This replaces the Emacs VPN command. The server, login type, username, and password live only in the pass entry `vpn` (override the name with `VPN_PASS_ENTRY`). The first line is the password. Leave it empty when the login type does not use one. Further lines are `key: value`:

```
server-name: vpn.example.com
user-name: optional
login-type: vpn_Example
ike-version: 1
```

`server-name` and `login-type` are required. Other snx-rs options can be added the same way. `log-level`, `keychain`, and `mfa-code` are refused: logging stays off, the password is not copied into the OS keychain, and a one-time code is not stored. Create or change the entry with `pass edit vpn`. The password store is separate from this repository.

`vpn connect` drops a tunnel that is already up, then connects. For an identity-provider login, snx-rs opens the browser itself. The command does not print the address, username, password, login type, or that URL. A password or MFA prompt is still shown. The tunnel stays up after the command returns.

```sh
vpn connect
vpn status
vpn disconnect
```

While `snxctl` is running, the command writes a mode `0600` config under the private temporary directory and overwrites that file before deleting it.

## Vicinae

Files: `~/.config/vicinae/shared.json`, which Vicinae reloads on save, and `~/.config/vicinae/settings.json`.

Vicinae owns the launcher and the app shortcuts, on macOS only so far. To give another app a shortcut, add its entry to `shared.json`. List the app IDs with `vicinae cmd ls | grep applications`.

| Shortcut | Action |
| --- | --- |
| Alt+1 | Focus WezTerm, launching it if it is not running |
| Alt+2 | Focus Zen Browser, launching it if it is not running |
| Alt+3 | Focus Cursor, launching it if it is not running |
| Alt+Space | Open the Vicinae launcher |

Vicinae rewrites `settings.json` whenever a setting changes in its window, which would replace a symlink with a regular file. So chezmoi creates it once, as a regular file that imports `shared.json`, and never touches it again. If Vicinae ran before the first `chezmoi apply`, the file already exists without the import. Add it by hand:

```json
"imports": ["./shared.json"]
```

## Amethyst

Files: `~/.config/amethyst/amethyst.yml`, on macOS only.

[Amethyst](https://ianyh.com/amethyst/) keeps every window at full screen size with its `fullscreen` layout, so one window is visible at a time. Alt+Shift+J and Alt+Shift+K cycle through the windows on the screen.

## Thaw

No files. [Thaw](https://www.getthaw.app/) hides menu bar icons behind a click on macOS. Keep Wi‑Fi, battery, and the clock always visible and put the rest in the hidden section. For Bluetooth, AirDrop, and similar toggles, prefer moving them into Control Center in System Settings.

## Ardia

Files: `~/.config/ardia/config.json`, `~/.config/ardia/profiles.json`, `~/.local/bin/sync-ardia-profiles`, and `~/.local/bin/sync-ardia-extensions`.

`config.json` holds the settings that differ from Ardia's defaults. Ardia reads it at launch and whenever it changes, and never writes it. `ardia config init` writes schema files beside it without overwriting it. Keep those schema files, and the Chromium profile in `~/Library/Application Support/com.ardia.browser`, out of this repository.

Settings that grant control (`cliControl`, custom search URLs, page engines) cannot go in `config.json`. Set them in Ardia's Settings on each computer.

`sync-ardia-profiles` makes a running Ardia match `profiles.json`, never the other way around. It creates each listed profile that is missing, applies the listed fields, puts the profiles in the file's order, and sets the default profile. It matches profiles by name and leaves unlisted profiles alone, after the listed ones. `shareDataWith` is applied only when a profile is created. `sync-ardia-profiles --dry-run` prints the plan. Profile colours are `plum`, `blue`, `purple`, `pink`, `red`, `orange`, `yellow`, `green`, and `neutral`.

Each profile's password manager is set by hand in Settings > Profiles > Passwords. Choose None, so Ardia does not offer to save or suggest passwords. Neither `config.json` nor `sync-ardia-profiles` can set it.

`sync-ardia-extensions` installs [Floccus](https://chromewebstore.google.com/detail/floccus-bookmarks-sync/fnaicdffflnofjppbagibeoednhnbjhg) for every profile. Ardia does not load Chromium platform policies (`ExtensionInstallForcelist` and a macOS configuration profile are ignored), so this script writes Chromium External Extensions JSON under `~/Library/Application Support/Chromium/External Extensions` and under Ardia's Chromium data dir. Quit and reopen Ardia after it runs. If Floccus is still missing, `sync-ardia-extensions --web-store` opens the Chrome Web Store page in each profile that lacks it so you can click Add. Floccus sync accounts still need configuring in each profile.
