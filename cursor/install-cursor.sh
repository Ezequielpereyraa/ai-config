#!/usr/bin/env bash
# install-cursor.sh — Sincroniza ai-config/cursor con ~/.cursor/skills
# Uso: ./cursor/install-cursor.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_SKILLS_DIR="$HOME/.cursor/skills"

echo "→ Cursor install desde: $REPO_DIR"
echo "→ Target: $CURSOR_SKILLS_DIR"
echo ""

mkdir -p "$CURSOR_SKILLS_DIR"

# 1 — Limpiar symlinks rotos en ~/.cursor/skills/
echo "Limpiando symlinks rotos..."
find "$CURSOR_SKILLS_DIR" -maxdepth 1 -type l | while read link; do
  if [ ! -e "$link" ]; then
    echo "  removing broken symlink: $link"
    rm "$link"
  fi
done

# 2 — Instalar skills desde ai-config/cursor/skills/
echo ""
echo "Instalando skills..."
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  dst="$CURSOR_SKILLS_DIR/$skill_name"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  backup: $dst → $dst.backup"
    mv "$dst" "$dst.backup"
  fi

  ln -sf "$skill_dir" "$dst"
  echo "  ✓ $dst → $skill_dir"
done

# 3 — Instrucciones para global rules
echo ""
echo "✅ Skills instaladas."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PASO MANUAL — Global Rules en Cursor:"
echo ""
echo "1. Abrí Cursor → Settings → General → Rules for AI"
echo "2. Copiá el contenido de:"
echo "   $REPO_DIR/global-rules.md"
echo "3. Pegalo en el campo de texto y guardá"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "TEMPLATES de project rules disponibles en:"
echo "   $REPO_DIR/project-rules/"
echo ""
echo "Para usar en un proyecto:"
echo "  mkdir -p .cursor/rules"
echo "  cp $REPO_DIR/project-rules/nextjs.mdc .cursor/rules/"
echo "  cp $REPO_DIR/project-rules/nestjs.mdc .cursor/rules/"
echo ""
