const { Plugin } = require('obsidian');

const EXPENSES_FOLDER = "02 ⚜️ Domains/03 💰 Finance/🗃️ Outputs/Expenses";

module.exports = class ExpenseAutoRename extends Plugin {
  async onload() {
    this.registerEvent(
      this.app.metadataCache.on('changed', (file) => {
        if (!file.path.startsWith(EXPENSES_FOLDER + "/")) return;
        if (file.extension !== 'md') return;

        const fm = this.app.metadataCache.getFileCache(file)?.frontmatter;
        if (!fm?.date) return;

        // Item part is everything after "YYYY-MM-DD " in the current basename
        const itemPart = file.basename.replace(/^\d{4}-\d{2}-\d{2}\s+/, '');
        const expectedName = `${fm.date} ${itemPart}`;

        if (file.basename === expectedName) return;

        const newPath = `${EXPENSES_FOLDER}/${expectedName}.md`;
        this.app.fileManager.renameFile(file, newPath).catch(e => {
          console.error('[expense-auto-rename] rename failed', e);
        });
      })
    );
  }
};
