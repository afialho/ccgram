#!/usr/bin/env bash
# install-ctl.sh — One-liner installer for ccgramctl
# Usage: curl -fsSL https://raw.githubusercontent.com/afialho/ccgram/main/scripts/install-ctl.sh | bash
#
# Installs ccgramctl to ~/.local/bin and ensures it's in PATH.

set -euo pipefail

REPO="afialho/ccgram"
BRANCH="main"
SCRIPT_NAME="ccgramctl"
INSTALL_DIR="${HOME}/.local/bin"
SOURCE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/scripts/${SCRIPT_NAME}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ${NC}  $*"; }
success() { echo -e "${GREEN}✓${NC}  $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }

echo ""
echo -e "${BOLD}Installing ccgramctl...${NC}"
echo ""

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download
info "Downloading from github.com/${REPO}..."
if command -v curl &>/dev/null; then
    curl -fsSL "$SOURCE_URL" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
elif command -v wget &>/dev/null; then
    wget -qO "${INSTALL_DIR}/${SCRIPT_NAME}" "$SOURCE_URL"
else
    echo "Error: curl or wget required"
    exit 1
fi

chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
success "Installed to ${INSTALL_DIR}/${SCRIPT_NAME}"

# Check PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    warn "${INSTALL_DIR} is not in your PATH"
    echo ""

    # Detect shell config file
    SHELL_CONFIG=""
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash"* ]]; then
        if [[ -f "$HOME/.bash_profile" ]]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        else
            SHELL_CONFIG="$HOME/.bashrc"
        fi
    fi

    if [[ -n "$SHELL_CONFIG" ]]; then
        EXPORT_LINE="export PATH=\"\$HOME/.local/bin:\$PATH\""

        # Only add if not already present
        if ! grep -qF '.local/bin' "$SHELL_CONFIG" 2>/dev/null; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Added by ccgramctl installer" >> "$SHELL_CONFIG"
            echo "$EXPORT_LINE" >> "$SHELL_CONFIG"
            success "Added ~/.local/bin to PATH in ${SHELL_CONFIG}"
            info "Run: source ${SHELL_CONFIG}"
        else
            info "~/.local/bin already referenced in ${SHELL_CONFIG}"
            info "Run: source ${SHELL_CONFIG}"
        fi
    else
        echo "  Add this to your shell config:"
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
else
    success "~/.local/bin is already in PATH"
fi

echo ""
echo -e "${BOLD}Done!${NC} Get started with:"
echo ""
echo "    ccgramctl setup     # First-time interactive setup"
echo "    ccgramctl help      # See all commands"
echo ""
