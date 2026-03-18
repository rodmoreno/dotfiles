#!/usr/bin/env bash
# symlink.sh — Crea symlinks de las configs del repo a sus ubicaciones en el sistema.
# Re-ejecutable de forma segura: hace backup de archivos existentes antes de sobreescribir.
# Uso: bash symlink.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################
# Colores para output
###############################################
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}→ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $1${NC}"; }

# link <origen_en_repo> <destino_en_sistema>
# Si el destino ya existe como archivo real, lo mueve a <destino>.bak antes de linkear.
link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backup: $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -sf "$src" "$dst"
  success "$dst → $src"
}

info "Creando symlinks..."

###############################################
# Zed
###############################################
link "$DOTFILES_DIR/config/zed/settings.json" \
     "$HOME/.config/zed/settings.json"

link "$DOTFILES_DIR/config/zed/keymap.json" \
     "$HOME/.config/zed/keymap.json"

###############################################
# Ghostty
###############################################
link "$DOTFILES_DIR/config/ghostty/config" \
     "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

###############################################
# Git
###############################################
link "$DOTFILES_DIR/config/git/config" \
     "$HOME/.config/git/config"

###############################################
# Claude Code
###############################################
link "$DOTFILES_DIR/config/claude/settings.json" \
     "$HOME/.claude/settings.json"

###############################################
# Starship
###############################################
link "$DOTFILES_DIR/config/starship.toml" \
     "$HOME/.config/starship.toml"

###############################################
# tmux
###############################################
link "$DOTFILES_DIR/config/tmux/tmux.conf" \
     "$HOME/.config/tmux/tmux.conf"

success "Symlinks OK"
