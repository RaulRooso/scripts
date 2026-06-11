#!/usr/bin/env bash

# Define target files and markers
BASHRC="$HOME/.bashrc"
MARKER="# === CUSTOM KDE KONSOLE PROMPT ENVIRONMENT ==="

# --- REGISTRATION BLOCK ---
# This part ONLY runs if we execute the script explicitly via ./prompt_setup.sh
# It handles the one-time setup of injecting the hook into ~/.bashrc
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -e
    trap 'echo "🗵 Script failed at line $LINENO"; exit 1' ERR

    echo -e '\n=============================================================================================================='
    echo -e '                                    Initializing Prompt Setup Infrastructure                                  '
    echo -e '=============================================================================================================='

    if grep -q "$MARKER" "$BASHRC"; then
        echo "☑ Prompt configuration hook already exists in ~/.bashrc, skipping modification."
    else
        cat << 'EOF' >> "$BASHRC"

# === CUSTOM KDE KONSOLE PROMPT ENVIRONMENT ===
if [ -f "$HOME/Scripts/prompt_setup.sh" ]; then
    source "$HOME/Scripts/prompt_setup.sh"
fi
EOF
        echo "☑ Successfully hooked prompt_setup.sh into ~/.bashrc"
    fi
    exit 0
fi

# --- LIVE PROMPT ENGINE ---
# This part runs every time a new terminal tab opens and "sources" this file!

# Explicit ANSI color definitions (Inspired by KWrite Dark Theme)
COLOR_RESET='\[\e[0m\]'
COLOR_TEAL='\[\e[38;5;37m\]'    # Accent color for identity
COLOR_WHITE='\[\e[38;5;255m\]'  # Crisp white text for paths
COLOR_GRAY='\[\e[38;5;244m\]'   # Dimmer gray for structural brackets
COLOR_KW_RED='\[\e[38;5;167m\]' # The muted, rustic KWrite syntax red

# The High-Performance Safety Switch (The One-Liner Guard)
# If $UID is 0 (root), use KWrite Red and a Warning Triangle. Otherwise, use your custom Teal arrow.
# arrow options ⟹, ➜, ->
[[ "$UID" -eq 0 ]] && ARROW_COLOR="${COLOR_KW_RED}" && ARROW_CHAR="▶" || ARROW_COLOR="${COLOR_TEAL}" && ARROW_CHAR="=>"

# Layout Components
PROMPT_TIME="${COLOR_GRAY}[${COLOR_GRAY}\D{%Y-%m-%d %H:%M:%S}${COLOR_GRAY}]"
PROMPT_IDENTITY="${COLOR_TEAL}\u${COLOR_GRAY}@${COLOR_TEAL}\h"
PROMPT_DIR="${COLOR_WHITE}\w"

# Final Multi-line Assembly
export PS1="${PROMPT_TIME} ${PROMPT_IDENTITY} ${COLOR_KW_RED}in ${PROMPT_DIR} \$(get_git_state)\n${ARROW_COLOR}${ARROW_CHAR}${COLOR_RESET} "

# --- DYNAMIC GIT ENGINE ---
# High-performance function to parse repository state directly from Git plumbing
get_git_state() {
    # Guard: Check if we are even inside a Git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi

    # Raw ANSI colors for dynamic function returns (No \[ \] wrappers allowed here!)
    local reset="\033[0m"
    local gray="\033[38;5;244m"
    local teal="\033[38;5;37m"
    local kw_red="\033[38;5;167m"

    # 1. Extract the current active branch name cleanly
    local branch
    branch=$(git branch --show-current 2>/dev/null)

    if [ -z "$branch" ]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi

    # 2. Check if the repository is "dirty"
    local status_indicator=""
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        status_indicator=" 🗵 "
    else
        status_indicator=" ☑ "
    fi

    # Echo the finalized string using clean, un-bracketed raw ANSI codes
    echo -e "${gray}(${teal}${branch}${kw_red}${status_indicator}${gray}) "
}
