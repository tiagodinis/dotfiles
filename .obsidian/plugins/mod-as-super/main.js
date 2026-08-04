const { Plugin } = require('obsidian');

// Map a DOM KeyboardEvent to Obsidian's hotkey "key" token.
function obsidianKey(ev) {
  const k = ev.key;
  if (/^[a-zA-Z]$/.test(k)) return k.toUpperCase();      // letters stored uppercase
  const special = {
    ' ': 'Space', 'Backspace': 'Backspace', 'Enter': 'Enter', 'Escape': 'Escape',
    'Tab': 'Tab', 'ArrowUp': 'ArrowUp', 'ArrowDown': 'ArrowDown',
    'ArrowLeft': 'ArrowLeft', 'ArrowRight': 'ArrowRight', 'Delete': 'Delete',
    '`': '`', ',': ',', '.': '.', ';': ';', '/': '/', '[': '[', ']': ']',
    "'": "'", '-': '-', '=': '=',
  };
  return special[k] !== undefined ? special[k] : (k.length === 1 ? k.toUpperCase() : k);
}

module.exports = class ModAsSuper extends Plugin {
  async onload() {
    // Linux only — on macOS "Mod" already means Cmd.
    if (process.platform !== 'linux') return;

    this.hotkeys = []; // [{id, mods:Set, key}]
    this._rebuild();
    try {
      if (this.app.hotkeyManager && this.app.hotkeyManager.on) {
        this.registerEvent(this.app.hotkeyManager.on('hotkey-change', () => this._rebuild()));
      }
    } catch (e) { /* internal API may differ across versions — rebuild lazily instead */ }

    // Capture on document keydown, before default text insertion.
    this.registerDomEvent(document, 'keydown', (ev) => this._onKey(ev), true);
  }

  _hotkeysPath() {
    const base = this.app.vault.adapter.basePath;
    return `${base}/.obsidian/hotkeys.json`;
  }

  // Rebuild: read the vault's hotkeys.json (source of truth) and index Mod-based
  // bindings so we can trigger them from the Super/⌘-position key on Linux.
  async _rebuild() {
    const fresh = [];
    try {
      const fs = require('fs');
      const raw = JSON.parse(fs.readFileSync(this._hotkeysPath(), 'utf8'));
      for (const [id, list] of Object.entries(raw)) {
        for (const h of (list || [])) {
          const mods = new Set(h.modifiers || []);
          if (!mods.has('Mod')) continue;            // only the primary ("Cmd"/Ctrl) bindings
          fresh.push({ id, mods, key: h.key });
        }
      }
    } catch (e) { /* file may not exist yet */ }
    this.hotkeys = fresh;
  }

  _onKey(ev) {
    if (!ev.metaKey) return;            // only when the ⌘-position (Super) key is held
    if (ev.ctrlKey) return;             // Ctrl combos stay native (Mod == Ctrl on Linux)

    const key = obsidianKey(ev);
    const wantShift = ev.shiftKey;
    const wantAlt = ev.altKey;

    for (const hk of this.hotkeys) {
      if (hk.key !== key) continue;
      if (hk.mods.has('Shift') !== wantShift) continue;
      if (hk.mods.has('Alt') !== wantAlt) continue;
      // Found: run the command bound to this Mod(+Shift/+Alt) chord from the
      // Super/⌘-position key, and stop Obsidian/text.
      ev.preventDefault();
      ev.stopPropagation();
      this.app.commands.executeCommandById(hk.id);
      return;
    }
  }
};
