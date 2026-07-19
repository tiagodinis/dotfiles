const { Plugin, PluginSettingTab, Setting, MarkdownView } = require('obsidian');

const DEFAULT_SETTINGS = {
  enableKeyRepeat: true,
  repeatInterval: 0, // ms between repeat steps; 0 = no throttle (OS rate)
};

// --- movement functions ---

function moveUp(doc, pos) {
  const line = doc.lineAt(pos);
  if (line.number <= 1) return 0;
  const col = pos - line.from;
  const prev = doc.line(line.number - 1);
  return prev.from + Math.min(col, prev.length);
}

function moveDown(doc, pos) {
  const line = doc.lineAt(pos);
  if (line.number >= doc.lines) return doc.length;
  const col = pos - line.from;
  const next = doc.line(line.number + 1);
  return next.from + Math.min(col, next.length);
}

function wordStartLeft(doc, pos) {
  if (pos === 0) return 0;
  const text = doc.sliceString(0, pos);
  let i = text.length - 1;
  while (i >= 0 && !/\w/.test(text[i])) i--;
  while (i >= 0 && /\w/.test(text[i])) i--;
  return i + 1;
}

function wordEndRight(doc, pos) {
  if (pos === doc.length) return doc.length;
  const text = doc.sliceString(pos);
  let i = 0;
  while (i < text.length && !/\w/.test(text[i])) i++;
  while (i < text.length && /\w/.test(text[i])) i++;
  return pos + i;
}

// e.code -> function(cm, sel) -> new head position.
// For char left/right: always pass a collapsed range at sel.head to moveByChar
// so it moves exactly one grapheme cluster from the head position, regardless
// of whether there is an existing selection.
const CODE_TO_MOVE = {
  KeyI:      (cm, sel) => moveUp(cm.state.doc, sel.head),
  KeyK:      (cm, sel) => moveDown(cm.state.doc, sel.head),
  KeyU:      (cm, sel) => cm.moveByChar(cm.state.selection.constructor.cursor(sel.head), false).head,
  KeyO:      (cm, sel) => cm.moveByChar(cm.state.selection.constructor.cursor(sel.head), true).head,
  KeyJ:      (cm, sel) => wordStartLeft(cm.state.doc, sel.head),
  KeyL:      (cm, sel) => wordEndRight(cm.state.doc, sel.head),
  KeyH:      (cm, sel) => cm.state.doc.lineAt(sel.head).from,
  Semicolon: (cm, sel) => cm.state.doc.lineAt(sel.head).to,
};

// --- settings tab ---

class SelectionShortcutsSettingTab extends PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display() {
    const { containerEl } = this;
    containerEl.empty();
    new Setting(containerEl)
      .setName('Enable key repeat')
      .setDesc('When a key is held down, the cursor keeps moving — same as holding an arrow key.')
      .addToggle(toggle => toggle
        .setValue(this.plugin.settings.enableKeyRepeat)
        .onChange(async (value) => {
          this.plugin.settings.enableKeyRepeat = value;
          await this.plugin.saveSettings();
        }));

    new Setting(containerEl)
      .setName('Repeat speed (ms between steps)')
      .setDesc('Minimum delay between repeat movements when a key is held. 0 = OS rate (fastest). Higher = slower.')
      .addSlider(slider => slider
        .setLimits(0, 200, 10)
        .setValue(this.plugin.settings.repeatInterval)
        .setDynamicTooltip()
        .onChange(async (value) => {
          this.plugin.settings.repeatInterval = value;
          await this.plugin.saveSettings();
        }));
  }
}

// --- plugin ---

module.exports = class SelectionShortcuts extends Plugin {
  async onload() {
    await this.loadSettings();
    this.addSettingTab(new SelectionShortcutsSettingTab(this.app, this));

    this._lastRepeat = 0; // timestamp of the last processed repeat event

    // Use capture phase so our handler fires before CM6's own keydown handlers.
    // Without this, CM6 processes the key first (e.g. cmd+u has a CM6 default
    // binding) and moves the cursor before we can intercept.
    this.registerDomEvent(document, 'keydown', (e) => {
      // Only act on Cmd combos (no Ctrl, no Alt/Option)
      if (!e.metaKey || e.ctrlKey || e.altKey) return;

      const moveFn = CODE_TO_MOVE[e.code];
      if (!moveFn) return;

      const view = this.app.workspace.getActiveViewOfType(MarkdownView);
      if (!view) return;
      const cm = view.editor.cm;
      if (!cm || !cm.dom.contains(document.activeElement)) return;

      // Always cancel the event once we own the key combo — even when skipping
      // or throttling — so CM6's default bindings (e.g. cmd+shift+k = deleteLine)
      // never fire on the events we swallow.
      e.preventDefault();
      e.stopImmediatePropagation();

      // Skip repeating keystrokes if the setting is off
      if (e.repeat && !this.settings.enableKeyRepeat) return;
      // Throttle repeats to the configured interval
      if (e.repeat && this.settings.repeatInterval > 0) {
        const now = Date.now();
        if (now - this._lastRepeat < this.settings.repeatInterval) return;
        this._lastRepeat = now;
      }

      const sel = cm.state.selection.main;
      const newHead = moveFn(cm, sel);
      // Shift held = extend selection; no shift = collapse cursor to new position
      const anchor = e.shiftKey ? sel.anchor : newHead;

      cm.dispatch(cm.state.update({
        selection: { anchor, head: newHead },
        scrollIntoView: true,
        userEvent: e.shiftKey ? 'select' : 'move',
      }));
    }, { capture: true });
  }

  async loadSettings() {
    this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
  }

  async saveSettings() {
    await this.saveData(this.settings);
  }
};
