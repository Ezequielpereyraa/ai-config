#!/bin/bash

# Gentleman theme — true-color powerline blocks
# Requires a Nerd Font for the chevron/cap glyphs (already working per prior icons)

rgb_bg() { printf '\033[48;2;%sm' "$1"; }
rgb_fg() { printf '\033[38;2;%sm' "$1"; }

BASE_RGB='30;30;46'        # dark text drawn on top of colored blocks
PRIMARY_RGB='127;180;202'  # #7FB4CA azul claro
ACCENT_RGB='224;193;90'    # #E0C15A dorado
SECONDARY_RGB='163;181;214' # #A3B5D6 azul gris
MUTED_RGB='92;97;112'      # #5C6170 gris
SUCCESS_RGB='183;204;133'  # #B7CC85 verde
ERROR_RGB='203;124;148'    # #CB7C94 rosa/rojo
PURPLE_RGB='201;154;214'   # #C99AD6 púrpura

BASE=$(rgb_fg "$BASE_RGB")
BOLD='\033[1m'
NC='\033[0m'

# Powerline glyphs (Nerd Font)
SEP=''      # U+E0B0 chevron
CAP_L=''    # U+E0B6 rounded left cap
CAP_R=''    # U+E0B4 rounded right cap
FOLDER='󰉋'
BRANCH_ICON=''

# Cache for MCP (don't call every 300ms)
MCP_CACHE_FILE="/tmp/claude_mcp_cache"
MCP_CACHE_TTL=120  # 2 minutes

# Read JSON from stdin
input=$(cat)

# Parse fields via jq (system package, siempre en PATH — a diferencia de node
# vía nvm, que no está disponible cuando Claude Code invoca este script fuera
# de una shell interactiva)
FIELDS=$(printf '%s' "$input" | jq -r '
  [
    (.model.display_name // "Claude"),
    (.workspace.current_dir // "~"),
    (.context_window.used_percentage // ""),
    (.cost.total_cost_usd // 0),
    (.cost.total_duration_ms // 0),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.rate_limits.seven_day.resets_at // "")
  ] | @tsv
' 2>/dev/null)
IFS=$'\t' read -r MODEL DIR CTX_PERCENT_RAW COST_USD DURATION_MS RL_5H RL_7D RL_7D_RESETS <<< "$FIELDS"

# Context window — pre-calculated field from Claude Code
if [ -n "$CTX_PERCENT_RAW" ]; then
  CTX_PERCENT=$(printf "%.0f" "$CTX_PERCENT_RAW")
else
  CTX_PERCENT=0
fi
[ "$CTX_PERCENT" -gt 100 ] && CTX_PERCENT=100
[ "$CTX_PERCENT" -lt 0 ] && CTX_PERCENT=0

# Cost / duration formatting
COST_FMT=$(awk -v c="$COST_USD" 'BEGIN { printf "$%.2f", c+0 }')
DURATION_FMT=$(awk -v ms="$DURATION_MS" 'BEGIN {
  s = int(ms / 1000); m = int(s / 60); h = int(m / 60)
  if (h > 0) printf "%dh%dm", h, m % 60
  else printf "%dm", m
}')

# Rate limits (5h/7d) — cuenta atras del reset semanal, solo si hay dato
RL_7D_RESET_FMT=""
if [ -n "$RL_7D_RESETS" ]; then
  SECS_LEFT=$(( RL_7D_RESETS - $(date +%s) ))
  if [ "$SECS_LEFT" -gt 0 ]; then
    D_LEFT=$((SECS_LEFT / 86400))
    H_LEFT=$(((SECS_LEFT % 86400) / 3600))
    if [ "$D_LEFT" -gt 0 ]; then
      RL_7D_RESET_FMT="${D_LEFT}d${H_LEFT}h"
    else
      RL_7D_RESET_FMT="${H_LEFT}h"
    fi
  else
    RL_7D_RESET_FMT="ya"
  fi
fi

RL_WORST=0
[ -n "$RL_5H" ] && [ "$RL_5H" -gt "$RL_WORST" ] 2>/dev/null && RL_WORST=$RL_5H
[ -n "$RL_7D" ] && [ "$RL_7D" -gt "$RL_WORST" ] 2>/dev/null && RL_WORST=$RL_7D

# Function to get MCP servers from config
get_mcp_servers() {
  if [ -f "$MCP_CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$MCP_CACHE_FILE" 2>/dev/null || stat -f %m "$MCP_CACHE_FILE" 2>/dev/null || echo 0)))
    if [ "$CACHE_AGE" -lt "$MCP_CACHE_TTL" ]; then
      cat "$MCP_CACHE_FILE"
      return
    fi
  fi

  local SERVERS
  SERVERS=$(jq -r --arg dir "$DIR" '.projects[$dir].mcpServers // {} | keys | join(",")' \
    "$HOME/.claude.json" 2>/dev/null)

  echo "$SERVERS" > "$MCP_CACHE_FILE"
  echo "$SERVERS"
}
MCP_SERVERS=$(get_mcp_servers)
MCP_COUNT=0
[ -n "$MCP_SERVERS" ] && MCP_COUNT=$(echo "$MCP_SERVERS" | tr ',' '\n' | wc -l | tr -d ' ')

# Directory name
DIR_NAME=$(basename "$DIR")

# Git info
BRANCH=""
GIT_DIRTY=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  if [[ -n $(git -C "$DIR" status --porcelain 2>/dev/null) ]]; then
    GIT_DIRTY="*"
  fi
fi

# Model icon
MODEL_ICON="🤖"
case "$MODEL" in
  *Opus*) MODEL_ICON="🎭" ;;
  *Sonnet*) MODEL_ICON="📝" ;;
  *Haiku*) MODEL_ICON="🍃" ;;
esac

# Context bar
BAR_WIDTH=8
FILLED=$((CTX_PERCENT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="▓"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

# Segment background colors (context segment shifts with usage)
if [ "$CTX_PERCENT" -ge 80 ]; then
  CTX_RGB="$ERROR_RGB"
elif [ "$CTX_PERCENT" -ge 50 ]; then
  CTX_RGB="$ACCENT_RGB"
else
  CTX_RGB="$SUCCESS_RGB"
fi
GIT_RGB="$SUCCESS_RGB"
[ -n "$GIT_DIRTY" ] && GIT_RGB="$ACCENT_RGB"

if [ "$RL_WORST" -ge 80 ]; then
  RL_RGB="$ERROR_RGB"
elif [ "$RL_WORST" -ge 50 ]; then
  RL_RGB="$ACCENT_RGB"
else
  RL_RGB="$SUCCESS_RGB"
fi

# Build powerline: cap -> model -> dir -> [git] -> context+cost -> [mcp] -> cap
LINE="${NC}$(rgb_fg "$PURPLE_RGB")${CAP_L}$(rgb_bg "$PURPLE_RGB")${BASE}${BOLD} ${MODEL_ICON} ${MODEL} "
PREV_RGB="$PURPLE_RGB"

LINE+="$(rgb_fg "$PREV_RGB")$(rgb_bg "$PRIMARY_RGB")${SEP}${BASE}${BOLD} ${FOLDER} ${DIR_NAME} "
PREV_RGB="$PRIMARY_RGB"

if [ -n "$BRANCH" ]; then
  LINE+="$(rgb_fg "$PREV_RGB")$(rgb_bg "$GIT_RGB")${SEP}${BASE}${BOLD} ${BRANCH_ICON} ${BRANCH}${GIT_DIRTY} "
  PREV_RGB="$GIT_RGB"
fi

LINE+="$(rgb_fg "$PREV_RGB")$(rgb_bg "$CTX_RGB")${SEP}${BASE}${BOLD} ${BAR} ${CTX_PERCENT}% ${COST_FMT} ${DURATION_FMT} "
PREV_RGB="$CTX_RGB"

if [ -n "$RL_5H" ] || [ -n "$RL_7D" ]; then
  RL_TXT="⏱ 5h ${RL_5H:-?}% · 7d ${RL_7D:-?}%"
  [ -n "$RL_7D_RESET_FMT" ] && RL_TXT+=" (${RL_7D_RESET_FMT})"
  LINE+="$(rgb_fg "$PREV_RGB")$(rgb_bg "$RL_RGB")${SEP}${BASE}${BOLD} ${RL_TXT} "
  PREV_RGB="$RL_RGB"
fi

if [ "$MCP_COUNT" -gt 0 ]; then
  LINE+="$(rgb_fg "$PREV_RGB")$(rgb_bg "$SECONDARY_RGB")${SEP}${BASE}${BOLD} 󰐻 ${MCP_COUNT} "
  PREV_RGB="$SECONDARY_RGB"
fi

LINE+="${NC}$(rgb_fg "$PREV_RGB")${CAP_R}${NC}"

echo -e "$LINE"
