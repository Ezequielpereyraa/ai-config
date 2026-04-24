#!/usr/bin/env bash
# install.sh — Sincroniza ai-config con ~/.claude
# Uso: ./install.sh
# Crea symlinks para CLAUDE.md, settings.json, statusline.sh y skills/

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "→ ai-config install desde: $REPO_DIR"
echo "→ Target: $CLAUDE_DIR"
echo ""

# Crear directorio si no existe
mkdir -p "$CLAUDE_DIR"

# Función para crear symlink con backup
link() {
  local src="$REPO_DIR/$1"
  local dst="$CLAUDE_DIR/$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  backup: $dst → $dst.backup"
    mv "$dst" "$dst.backup"
  fi

  ln -sf "$src" "$dst"
  echo "  ✓ $dst → $src"
}

# Archivos principales
link "CLAUDE.md"      "CLAUDE.md"
link "settings.json"  "settings.json"

# statusline solo si existe
if [ -f "$REPO_DIR/statusline.sh" ]; then
  link "statusline.sh" "statusline.sh"
fi

# Función para linkear directorios completos (con backup si existe y no es symlink)
link_dir() {
  local src="$REPO_DIR/$1"
  local dst="$CLAUDE_DIR/$1"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -d "$dst" ]; then
    echo "  backup: $dst → $dst.backup"
    mv "$dst" "$dst.backup"
  fi

  ln -sf "$src" "$dst"
  echo "  ✓ $dst → $src"
}

# Directorios completos
link_dir "skills"
link_dir "commands"
link_dir "output-styles"

echo ""
echo "✅ Listo. Reiniciá Claude Code para aplicar los cambios."
