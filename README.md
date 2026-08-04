# dotfiles

Personal configuration, saved from and restored to machines through two lanes:

| Lane | Targets |
|---|---|
| `mac` | `git` `zsh` `vscode` `obsidian` `copilot` · `brew` `iterm` `rectangle` `macos` |
| `omarchy` | `git` `zsh` `vscode` `obsidian` `copilot` · `hypr` `handy` `fcitx5` `keyd` |

## Usage

`package.json` only wires two thin aliases; all the logic lives in `scripts/dotfiles.sh`.

```bash
npm run save                     # save every applicable target on this machine
npm run restore                  # restore every applicable target

npm run save mac                 # a whole lane
npm run restore omarchy
npm run save omarchy hypr        # a single target inside a lane
npm run restore mac zsh
```

Targets that don't apply to the current OS are skipped with a note, so the same
command is safe to run on both the Mac and Omarchy.

```bash
bash scripts/dotfiles.sh help    # full usage
bash scripts/dotfiles.sh list    # the target registry
```

## Layout

- `bootstrap.sh` — fresh-machine entry point: clones the repo, picks the platform,
  then runs `scripts/<mac|linux>/bootstrap.sh`
- `scripts/mac/bootstrap.sh` — macOS lane setup (Homebrew, Brewfile, nvm, then restore)
- `scripts/linux/bootstrap.sh` — Omarchy lane setup (package delta, then restore)
- `scripts/dotfiles.sh` — dispatcher (lanes, targets, ordering)
- `scripts/lib.sh` — shared apps (VS Code, Obsidian, Copilot) + per-OS paths
- `scripts/mac.sh` — mac lane targets
- `scripts/omarchy.sh` — omarchy lane targets, plus the prune step the bootstrap runs
- `scripts/{mac,linux}/paths.sh` — per-OS paths used by `lib.sh`
- `VSCode/settings.json` + `VSCode/keybindings.json` — **one** pair for both platforms
  (platform differences use platform-scoped keys, e.g.
  `terminal.integrated.defaultProfile.osx` / `.linux`)

Lane-specific notes live in [`omarchy/README.md`](./omarchy/README.md) and
[`copilot/README.md`](./copilot/README.md).

## Fresh install

One entry point on either platform:

```bash
curl -fsSL https://raw.githubusercontent.com/tiagodinis/dotfiles/master/bootstrap.sh | bash

bash bootstrap.sh --dry-run   # preview every step, change nothing
bash bootstrap.sh --yes       # skip the Omarchy removal prompt
```

`bootstrap.sh` clones the repo with plain `git` (no auth needed), picks the lane
from the platform, then hands off to `scripts/<mac|linux>/bootstrap.sh`:

- **mac** → Homebrew → `Brewfile` (casks, npm tools, VS Code extensions) →
  Chrome cache fix → nvm + LTS Node → `restore mac`.
- **linux** → the Omarchy lane from [`omarchy/README.md`](./omarchy/README.md):
  drops the unwanted defaults and Voxtype (after a prompt), installs `handy-bin`,
  `google-chrome` and `firefox`, prunes orphaned deps → `restore omarchy`.

Both are idempotent, so re-running is safe.
