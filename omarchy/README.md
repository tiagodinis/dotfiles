# Omarchy lane (Linux / Arch + Hyprland)

Customizations for this Omarchy box: hotkey model, package delta, and the
save/restore commands. Deliberately one file — exact binds and settings live in
the actual configs this lane carries.

## Layout

```
omarchy/
├── hypr/              # → ~/.config/hypr
│   ├── hyprland.lua   # entry: Omarchy defaults + user modules + window rules
│   ├── bindings.lua   # keybindings (unbind defaults, ALT scheme)
│   ├── input.lua      # pointer/touchpad (keyboard mapping is keyd's job)
│   ├── monitors.lua   # eDP-1 + HDMI-A-1 layout and workspace rules
│   └── handy-ptt.sh   # Handy hold-to-talk bridge
├── handy/             # settings.json (keys restore applies) + apply-settings.py
├── fcitx5/conf/       # quickphrase.conf — Quick Phrase trigger disabled
└── etc/keyd/          # default.conf (HP keyboard) + magic.conf (Magic Keyboard)
```

## Usage

- `npm run save omarchy` / `npm run restore omarchy` — repo ↔ live.
- One target: `npm run restore omarchy hypr` (`hypr`, `fcitx5`, `keyd`, `handy`).
  `hypr` also reloads Hyprland; `keyd` needs sudo; `handy` stops/merges/restarts
  the app (its store caches settings in memory).
- Prune (drops unwanted software) is not a command — `scripts/linux/bootstrap.sh`
  runs it after a prompt, and a full restore also removes Voxtype.

## Hotkeys

> The key next to the spacebar is **SUPER/⌘** on every keyboard; Windows/⊞ is
> **Alt**. Holding ⌘ and pressing a letter behaves like macOS everywhere.

Three layers, each owning only what it can see:

| Layer | Owner | Owns |
|---|---|---|
| 0 | **keyd** (`etc/keyd/*.conf`) | physical SUPER/Alt, mac app chords (`⌘+S`→`Ctrl+S`, …) |
| 1 | **Hyprland** (`hypr/bindings.lua`) | window actions on ALT; frees SUPER combos for apps |
| 2 | **Apps** | VS Code (`meta`), Obsidian (`mod-as-super` plugin) |

Rules — binds live in `bindings.lua`, physical remaps in the keyd confs:

- **keyd does all remapping** (not xkb, not `wtype`); the HP keyboard swaps
  Alt/Super, the Magic Keyboard doesn't. Never re-add an xkb swap in `input.lua`.
- **Free a combo before an app can use it** — hence the `hl.unbind()` + `o.bind()`
  pairs. Window actions moved to ALT, keeping SUPER free for "⌘" shortcuts.
- **Copy/paste/cut are keyd chords, not Hyprland injection** — injecting while
  SUPER is held resets the compositor's held-modifier state.
- **VS Code uses `meta`, never `super`** (Linux ignores `super`); menu mnemonics
  are off so Alt reaches the WM/editor.
- **Obsidian can't persist SUPER** → `mod-as-super` replays the `Mod` command; a
  combo only works via SUPER if `hotkeys.json` has a `Mod` row.
- **Handy dictation is WM-driven** hold-to-talk on `ALT+Q`; its own X11 shortcut
  can't register under Hyprland. The first press after login only launches it.

Gotchas:

- A mod-only release bind that needs the mod never fires — use
  `ignore_mods = true`, or hook a non-mod key release.
- keyd `c/v/x` are real `Ctrl` chords, so terminals see interrupt/quoted-insert.
- Deliberate remaining Obsidian↔WM Alt overlaps: `Alt+O` (go-right vs pop-out),
  `Alt+F` (plugin fullscreen vs WM fullscreen).

## Packages

Fresh-install delta: what to remove from Omarchy's defaults and what to add.
Everything below is *explicitly installed*, so it's safe to drop. Base set:
`/usr/share/omarchy/install/omarchy-base.packages`.

| Remove | Package | Also |
|---|---|---|
| Webapps | *(launchers, not packages)* | `.desktop` PWAs |
| Cliamp | `cliamp` | `SUPER+SHIFT+ALT+M` binding |
| Moonlight | `moonlight-qt` | window rule |
| OBS Studio | `obs-studio` | window rule |
| Xournal++ | `xournalpp` | shipped config |
| Voxtype | `voxtype-bin` (AUR) | replaced by Handy |

| Install | Package | Source |
|---|---|---|
| Handy (speech-to-text) | `handy-bin` | AUR |
| Google Chrome | `google-chrome` | AUR |
| Firefox | `firefox` | extra |

```bash
# Remove
omarchy-webapp-remove-all
omarchy pkg drop cliamp moonlight-qt obs-studio xournalpp
rm -rf ~/.config/xournalpp
# Voxtype (AUR package + unit + update hook + config) is removed by the
# scripted prune: `npm run restore omarchy` or scripts/linux/bootstrap.sh.

# Install
omarchy pkg aur add handy-bin google-chrome
omarchy pkg add firefox
```

`bootstrap.sh` / `scripts/linux/bootstrap.sh` run all of this (`--dry-run` to
preview, `--yes` to skip the prompt), then restore the lane.

Package notes:

- **Webapps aren't packages** — their launchers are recreated by the preinstalled
  keybindings. After `omarchy-webapp-remove-all`, either unbind those keys in
  `bindings.lua`, or set `omarchy_preinstalled_bindings = false` before the
  default `require` in `hyprland.lua` (that flag also drops the other
  preinstalled-app bindings).
- `omarchy pkg drop` = `sudo pacman -Rns --noconfirm` on what's installed.
- Re-running the Omarchy **installer** puts these packages back — re-apply;
  migrations and `omarchy update` won't.
- Leftovers pacman won't clean: keybindings, `~/.config/omarchy/hooks/*.d/`,
  `~/.config/autostart/`, `~/.config/<app>`, `~/.local/share/<app>`.
- Don't remove system deps (bluez, cups, docker, fcitx5, hyprland, quickshell, …).
- **Handy after install:** download a model and pick a microphone on first run,
  and note `handy-bin` ≠ `libhandy` (a GTK system lib — leave it).

## Applying / validating

```bash
npm run save omarchy       # repo <- live
npm run restore omarchy    # live <- repo (sudo for /etc/keyd)
```

- **Hyprland**: `hyprctl reload` + `hyprctl configerrors` (restore already reloads).
- **keyd**: `keyd check <file>`, then `sudo systemctl restart keyd`.
- **Obsidian**: copy changed files into the live vault, then restart the app so
  `mod-as-super` reloads.
