#!/usr/bin/env bash
# ai.sh — CLI para instalar y actualizar ai-config
#
# Uso:
#   ./ai.sh install           # instala todo (claude + cursor)
#   ./ai.sh install claude    # solo claude
#   ./ai.sh install cursor    # solo cursor
#   ./ai.sh update            # git pull + sincroniza todo
#   ./ai.sh update claude     # git pull + solo claude
#   ./ai.sh update cursor     # git pull + solo cursor

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── helpers ────────────────────────────────────────────────────────────────

print_usage() {
  echo "Uso: ./ai.sh <comando> [target]"
  echo ""
  echo "Comandos:"
  echo "  install [claude|cursor]   Instala symlinks (default: todo)"
  echo "  update  [claude|cursor]   git pull + sincroniza (default: todo)"
  echo ""
  echo "Ejemplos:"
  echo "  ./ai.sh install"
  echo "  ./ai.sh install cursor"
  echo "  ./ai.sh update"
  echo "  ./ai.sh update claude"
}

run_install_claude() {
  echo "▸ Instalando Claude Code config..."
  bash "$REPO_DIR/install.sh"
}

run_install_cursor() {
  echo "▸ Instalando Cursor config..."
  bash "$REPO_DIR/cursor/install-cursor.sh"
}

run_git_pull() {
  echo "▸ Actualizando repo..."
  git -C "$REPO_DIR" pull
  echo ""
}

# ─── comandos ───────────────────────────────────────────────────────────────

cmd_install() {
  local target="${1:-all}"

  case "$target" in
    all)
      run_install_claude
      echo ""
      run_install_cursor
      ;;
    claude)
      run_install_claude
      ;;
    cursor)
      run_install_cursor
      ;;
    *)
      echo "Target inválido: '$target'. Usá: claude | cursor"
      exit 1
      ;;
  esac
}

cmd_update() {
  local target="${1:-all}"

  run_git_pull

  case "$target" in
    all)
      run_install_claude
      echo ""
      run_install_cursor
      ;;
    claude)
      run_install_claude
      ;;
    cursor)
      run_install_cursor
      ;;
    *)
      echo "Target inválido: '$target'. Usá: claude | cursor"
      exit 1
      ;;
  esac
}

# ─── entry point ────────────────────────────────────────────────────────────

case "${1:-}" in
  install)
    cmd_install "${2:-all}"
    ;;
  update)
    cmd_update "${2:-all}"
    ;;
  help|--help|-h|"")
    print_usage
    ;;
  *)
    echo "Comando desconocido: '$1'"
    echo ""
    print_usage
    exit 1
    ;;
esac
