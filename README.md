# ai-config

> Personal configuration files for **Claude** (Anthropic) and **Cursor** (AI code editor), ready to install with a single shell command.

---

## 📦 What's included

| Tool | Config file | Description |
|------|-------------|-------------|
| **Claude** | `claude/settings.json` | Custom preferences for Claude (Anthropic's AI assistant) |
| **Cursor** | `cursor/settings.json` | Editor settings and AI behaviour for Cursor IDE |

---

## 🚀 Quick install

### Install both configurations at once

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Ezequielpereyraa/ai-config/main/install.sh)"
```

### Install only Claude

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Ezequielpereyraa/ai-config/main/install.sh)" -- --claude
```

### Install only Cursor

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Ezequielpereyraa/ai-config/main/install.sh)" -- --cursor
```

> **Note:** If a config file already exists it will be backed up automatically as `settings.json.bak` before being replaced.

---

## 🛠️ Manual install

If you prefer to install manually, clone the repo and copy the files yourself:

```sh
# Clone the repository
git clone https://github.com/Ezequielpereyraa/ai-config.git
cd ai-config

# Claude
mkdir -p ~/.config/claude
cp claude/settings.json ~/.config/claude/settings.json

# Cursor
mkdir -p ~/.cursor
cp cursor/settings.json ~/.cursor/settings.json
```

---

## 📁 Repository structure

```
ai-config/
├── claude/
│   └── settings.json      # Claude configuration
├── cursor/
│   └── settings.json      # Cursor configuration
├── install.sh             # Automated installer
└── README.md
```

---

## ⚙️ Requirements

- `curl` — to download the files (pre-installed on most systems)
- `git` — only required for the manual install path

---

## 📄 License

MIT — feel free to fork and adapt to your own workflow.
