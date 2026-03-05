#!/usr/bin/env bash
# install.sh - Installs Claude and Cursor AI configurations
# Usage: sh install.sh [--claude | --cursor]
#   (no argument)  Install both Claude and Cursor configurations
#   --claude       Install only the Claude configuration
#   --cursor       Install only the Cursor configuration

set -e

REPO_URL="https://raw.githubusercontent.com/Ezequielpereyraa/ai-config/main"
CLAUDE_CONFIG_DIR="$HOME/.config/claude"
CURSOR_CONFIG_DIR="$HOME/.cursor"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ─── Dependency check ────────────────────────────────────────────────────────
check_dependencies() {
  for cmd in curl git; do
    command -v "$cmd" >/dev/null 2>&1 || error "'$cmd' is required but not installed."
  done
}

# ─── Claude configuration ────────────────────────────────────────────────────
install_claude() {
  info "Installing Claude configuration..."
  mkdir -p "$CLAUDE_CONFIG_DIR"

  if [ -f "$CLAUDE_CONFIG_DIR/settings.json" ]; then
    warn "Claude settings.json already exists. Backing up to settings.json.bak"
    cp "$CLAUDE_CONFIG_DIR/settings.json" "$CLAUDE_CONFIG_DIR/settings.json.bak"
  fi

  curl -fL --show-error "$REPO_URL/claude/settings.json" -o "$CLAUDE_CONFIG_DIR/settings.json" \
    || error "Failed to download Claude settings.json from $REPO_URL/claude/settings.json"
  info "Claude configuration installed at $CLAUDE_CONFIG_DIR/settings.json"
}

# ─── Cursor configuration ────────────────────────────────────────────────────
install_cursor() {
  info "Installing Cursor configuration..."
  mkdir -p "$CURSOR_CONFIG_DIR"

  if [ -f "$CURSOR_CONFIG_DIR/settings.json" ]; then
    warn "Cursor settings.json already exists. Backing up to settings.json.bak"
    cp "$CURSOR_CONFIG_DIR/settings.json" "$CURSOR_CONFIG_DIR/settings.json.bak"
  fi

  curl -fL --show-error "$REPO_URL/cursor/settings.json" -o "$CURSOR_CONFIG_DIR/settings.json" \
    || error "Failed to download Cursor settings.json from $REPO_URL/cursor/settings.json"
  info "Cursor configuration installed at $CURSOR_CONFIG_DIR/settings.json"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║        ai-config  installer          ║"
  echo "║   Claude + Cursor configurations     ║"
  echo "╚══════════════════════════════════════╝"
  echo ""

  check_dependencies

  # Allow selective installation via arguments: --claude | --cursor | (none = both)
  case "${1:-all}" in
    --claude) install_claude ;;
    --cursor) install_cursor ;;
    all)
      install_claude
      install_cursor
      ;;
    *)
      error "Unknown argument '$1'. Usage: sh install.sh [--claude | --cursor]"
      ;;
  esac

  echo ""
  info "Done! Restart Claude / Cursor to apply the new settings."
}

main "$@"
