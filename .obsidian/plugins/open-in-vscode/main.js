const { Plugin, Notice, PluginSettingTab, Setting } = require('obsidian');
const { exec } = require('child_process');
const path = require('path');

const DEFAULT_SETTINGS = {
  executablePath: '/usr/local/bin/code',
};

class OpenInVSCodeSettingTab extends PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display() {
    const { containerEl } = this;
    containerEl.empty();
    new Setting(containerEl)
      .setName('Executable path')
      .setDesc('Full path to the editor CLI (e.g. /usr/local/bin/code, /usr/local/bin/cursor)')
      .addText(text => text
        .setPlaceholder('/usr/local/bin/code')
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
        const code = this.settings.executablePath;
        const args = activeFile
          ? `"${vaultPath}" --goto "${path.join(vaultPath, activeFile.path)}"`
          : `"${vaultPath}"`;

        exec(`"${code}" ${args}`, (err) => {
          if (err) new Notice(`Open in VS Code failed: ${err.message}`);
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
