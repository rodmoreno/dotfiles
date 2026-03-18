#!/usr/bin/env bash
# run.sh — Entry point del setup completo
# Ejecuta bootstrap → install → macos en orden.
# Uso: bash run.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################
# Colores para output
###############################################
YELLOW='\033[1;33m'
NC='\033[0m'

warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

echo ""
echo "╔══════════════════════════════════════╗"
echo "║        Mac Clean Install Setup       ║"
echo "╚══════════════════════════════════════╝"
echo ""

bash "$DOTFILES_DIR/bootstrap.sh"
bash "$DOTFILES_DIR/install.sh"
bash "$DOTFILES_DIR/symlink.sh"
bash "$DOTFILES_DIR/macos.sh"

###############################################
# Limpieza
###############################################
brew cleanup

###############################################
# Resumen final
###############################################
echo ""
echo "╔══════════════════════════════════════╗"
echo "║           Setup Completado ✓         ║"
echo "╚══════════════════════════════════════╝"
echo ""

warn "FileVault — estado actual:"
sudo fdesetup status
echo ""

echo "Pasos manuales pendientes:"
echo ""
echo "   1. Reiniciar sesión o la Mac para aplicar todos los cambios"
echo ""
echo "   2. Activar FileVault si no está activo:"
echo "      sudo fdesetup enable"
echo ""
echo "   3. Autenticar Claude Code:"
echo "      claude  (sigue el flujo OAuth con tu cuenta Claude)"
echo ""
echo "   4. Abrir 1Password y vincular tu cuenta"
echo ""
