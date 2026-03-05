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

# Skills: symlink del directorio completo
if [ -L "$CLAUDE_DIR/skills" ]; then
  rm "$CLAUDE_DIR/skills"
elif [ -d "$CLAUDE_DIR/skills" ]; then
  echo "  backup: $CLAUDE_DIR/skills → $CLAUDE_DIR/skills.backup"
  mv "$CLAUDE_DIR/skills" "$CLAUDE_DIR/skills.backup"
fi
ln -sf "$REPO_DIR/skills" "$CLAUDE_DIR/skills"
echo "  ✓ $CLAUDE_DIR/skills → $REPO_DIR/skills"

echo ""
echo "✅ Listo. Reiniciá Claude Code para aplicar los cambios."
