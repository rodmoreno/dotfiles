#!/usr/bin/env bash
# bootstrap.sh — Prerequisitos del sistema
# Instala Xcode CLT y Homebrew, luego delega los paquetes al Brewfile.
# Uso: bash bootstrap.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################
# Colores para output
###############################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}→ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $1${NC}"; }
error()   { echo -e "${RED}✗ $1${NC}"; exit 1; }

###############################################
# Xcode Command Line Tools
###############################################
if ! xcode-select -p &>/dev/null; then
  info "Instalando Xcode Command Line Tools..."
  xcode-select --install
  warn "Espera a que termine la instalación de Xcode CLT y vuelve a ejecutar el script."
  exit 1
fi
success "Xcode Command Line Tools OK"

###############################################
# Homebrew
###############################################
if ! command -v brew &>/dev/null; then
  info "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

info "Actualizando Homebrew..."
brew update && brew upgrade
success "Homebrew OK"

###############################################
# Paquetes via Brewfile
###############################################
info "Instalando paquetes desde Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"
success "Paquetes OK"
