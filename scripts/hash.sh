#!/bin/bash

# Create directories
mkdir -p new

# Create a Node.js script to process the banlists
cat << 'EOF' > process_banlists.js
const fs = require('fs');
const path = require('path');

class BanList {
  constructor() {
    this.forbidden = [];
    this.limited = [];
    this.semiLimited = [];
    this.all = [];
    this._hash = 0x7dfcee6a;
    this.name = null;
  }

  add(cardId, quantity) {
    if (isNaN(cardId)) {
      return;
    }

    if (quantity === 0) {
      this.forbidden.push(cardId);
    }

    if (quantity === 1) {
      this.limited.push(cardId);
    }

    if (quantity === 2) {
      this.semiLimited.push(cardId);
    }

    if (quantity === 3) {
      this.all.push(cardId);
    }

    this._hash =
      this._hash ^
      ((((cardId >>> 0) << 18) >> 0) | (cardId >> 14)) ^
      ((((cardId >>> 0) << (27 + quantity)) >>> 0) | (cardId >>> (5 - quantity)));
  }

  setName(name) {
    this.name = name;
  }

  whileListed() {
    // Implementar la lógica que necesites para whileListed
  }

  load(filePath) {
    const lines = fs.readFileSync(filePath, "utf-8").split("\n");
    for (const line of lines) {
      if (!line) {
        continue;
      }

      if (line.startsWith("$whitelist")) {
        this.whileListed();
      }

      if (line.startsWith("#")) {
        continue;
      }

      if (line.startsWith("!")) {
        this.setName(line.substring(1).trim());
      }

      if (!line.includes(" ")) {
        continue;
      }

      if (this.name === null) {
        continue;
      }

      const [cardId, quantity] = line.split(" ");
      this.add(Number(cardId), Number(quantity));
    }
  }

  updateFile(filePath) {
    const lines = fs.readFileSync(filePath, "utf-8").split("\n");
    const updatedLines = lines.map(line => {
      if (line.startsWith("#[")) {
        return line.replace(/#\[([^\]]+)\]/, '#[$1 KS]');
      } else if (line.startsWith("!")) {
        return line.replace(/^!(.+)$/, '!$1 KS');
      }
      return line;
    });
    fs.writeFileSync(filePath, updatedLines.join("\n"), "utf-8");
  }
}

function processBanlists(dir) {
  const files = fs.readdirSync(dir);
  const hashes = [];

  files.forEach(file => {
    const filePath = path.join(dir, file);
    if (fs.lstatSync(filePath).isFile() && file.endsWith('.conf')) {
      const banList = new BanList();
      banList.load(filePath);
      console.log(`Path: ${filePath}`);
      console.log(`Banlist: ${banList.name}, Hash: ${banList._hash}`);
      hashes.push({ hash: banList._hash, file: file });
    }
  });

  return hashes;
}

const projectignisDir = 'projectignis';
const koishiDir = 'koishi';

const projectignisHashes = processBanlists(projectignisDir);
const koishiHashes = processBanlists(koishiDir);

const newFilesDir = 'new';

koishiHashes.forEach(({ hash, file }) => {
  if (!projectignisHashes.some(item => item.hash === hash)) {
    const filePath = path.join(koishiDir, file);
    const newFilePath = path.join(newFilesDir, file);

    fs.copyFileSync(filePath, newFilePath);

    const banList = new BanList();
    banList.updateFile(newFilePath);
  }
});
EOF

# Execute the Node.js script
node process_banlists.js

# Clean up the Node.js script
rm process_banlists.js

# List the generated files
echo "Archivos en new:"
ls -l new
