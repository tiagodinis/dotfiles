const { Plugin, Notice, PluginSettingTab, Setting } = require('obsidian');
const { exec } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const DEFAULT_SETTINGS = {
  // Empty = auto-detect. Override with a full path if auto-detection fails.
  executablePath: '',
};

// Common install locations for the VS Code / Cursor CLI, across Linux & macOS.
function candidatePaths() {
  const home = os.homedir();
  return [
    '/usr/bin/code',            // Arch / Omarchy / most distros
    '/usr/local/bin/code',      // macOS Intel / older brew
    '/opt/homebrew/bin/code',   // macOS Apple Silicon brew
    '/snap/bin/code',           // snap installs
    path.join(home, '.local/bin/code'),
    '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code',
    path.join(home, 'Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'),
  ];
}

// Returns a working CLI path: override (if set & exists) -> known candidates.
// Falls back to 'code' (resolved from PATH by the shell) when nothing matches.
function resolveEditor(override) {
  if (override && fs.existsSync(override)) {
    return override;
  }
  for (const p of candidatePaths()) {
    if (fs.existsSync(p)) return p;
  }
  return 'code';
}

class OpenInVSCodeSettingTab extends PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display() {
    const { containerEl } = this;
    containerEl.empty();
    new Setting(containerEl)
      .setName('Executable path (optional)')
      .setDesc('Full path to the editor CLI. Leave empty to auto-detect '
        + '(e.g. /usr/bin/code on Linux, /opt/homebrew/bin/code on macOS).')
      .addText(text => text
        .setPlaceholder('auto-detect')
        .setValue(this.plugin.settings.executablePath)
        .onChange(async (value) => {
          this.plugin.settings.executablePath = value.trim();
          await this.plugin.saveSettings();
        }));
  }
}

module.exports = class OpenInVSCode extends Plugin {
  async onload() {
    await this.loadSettings();
    this.addSettingTab(new OpenInVSCodeSettingTab(this.app, this));

    this.addCommand({
      id: 'open-in-vscode',
      name: 'Open in VS Code',
      callback: () => {
        const vaultPath = this.app.vault.adapter.basePath;
        const activeFile = this.app.workspace.getActiveFile();
        const code = resolveEditor(this.settings.executablePath);
        const args = activeFile
          ? `"${vaultPath}" --goto "${path.join(vaultPath, activeFile.path)}"`
          : `"${vaultPath}"`;

        exec(`"${code}" ${args}`, (err) => {
          if (err) {
            new Notice('Open in VS Code failed: is the `code` CLI installed? '
              + 'Set the executable path in the plugin settings.');
          }
        });
      }
    });
  }

  async loadSettings() {
    this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
  }

  async saveSettings() {
    await this.saveData(this.settings);
  }
};
