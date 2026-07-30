#!/usr/bin/env bash
# install.sh — Sincroniza ai-config con herramientas IA en Unix/macOS
# Uso: ./install.sh [all|claude|opencode|codex]

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
OPENCODE_DIR="$HOME/.config/opencode"
CODEX_DIR="$HOME/.codex"
CODEX_RULES_DIR="$HOME/.codex/rules"
TARGET="${1:-all}"

echo "→ ai-config install desde: $REPO_DIR"
echo "→ Claude target: $CLAUDE_DIR"
echo "→ OpenCode target: $OPENCODE_DIR"
echo "→ Codex target: $CODEX_DIR"
echo "→ Codex rules target: $CODEX_RULES_DIR"
echo ""

mkdir -p "$CLAUDE_DIR" "$OPENCODE_DIR" "$CODEX_DIR" "$CODEX_RULES_DIR"

link() {
  local src="$REPO_DIR/$1"
  local dst="$2/$3"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup="$dst.backup"
    echo "  backup: $dst → $backup"
    rm -rf "$backup"
    mv "$dst" "$backup"
  fi

  ln -sf "$src" "$dst"
  echo "  ✓ $dst → $src"
}

link_dir() {
  local src="$REPO_DIR/$1"
  local dst="$2/$3"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup="$dst.backup"
    echo "  backup: $dst → $backup"
    rm -rf "$backup"
    mv "$dst" "$backup"
  fi

  ln -sf "$src" "$dst"
  echo "  ✓ $dst → $src"
}

install_claude() {
  link "CLAUDE.md" "$CLAUDE_DIR" "CLAUDE.md"
  link "settings.json" "$CLAUDE_DIR" "settings.json"

  if [ -f "$REPO_DIR/statusline.sh" ]; then
    link "statusline.sh" "$CLAUDE_DIR" "statusline.sh"
  fi

  link_dir "skills" "$CLAUDE_DIR" "skills"
    link_dir "commands" "$CLAUDE_DIR" "commands"
}

install_opencode() {
  if [ -f "$REPO_DIR/opencode/opencode.jsonc" ]; then
    link "opencode/opencode.jsonc" "$OPENCODE_DIR" "opencode.jsonc"
  fi

  if [ -f "$REPO_DIR/opencode/tui.json" ]; then
    link "opencode/tui.json" "$OPENCODE_DIR" "tui.json"
  fi

  if [ -d "$REPO_DIR/opencode/plugins" ]; then
    link_dir "opencode/plugins" "$OPENCODE_DIR" "plugins"
  fi

  link_dir "skills" "$OPENCODE_DIR" "skills"
  link_dir "commands" "$OPENCODE_DIR" "commands"
}

install_codex() {
  if [ -f "$REPO_DIR/codex/AGENTS.md" ]; then
    link "codex/AGENTS.md" "$CODEX_DIR" "AGENTS.md"
  fi

  if [ -f "$REPO_DIR/codex/rules/default.rules" ]; then
    link "codex/rules/default.rules" "$CODEX_RULES_DIR" "default.rules"
  fi
}

case "$TARGET" in
  all)
    install_claude
    install_opencode
    install_codex
    ;;
  claude)
    install_claude
    ;;
  opencode)
    install_opencode
    ;;
  codex)
    install_codex
    ;;
  *)
    echo "Target inválido: '$TARGET'. Usá: all | claude | opencode | codex"
    exit 1
    ;;
esac

echo ""
echo "✅ Listo. Reiniciá las herramientas abiertas para aplicar los cambios."
