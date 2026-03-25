#!/usr/bin/env bash
# install.sh — Configuración de herramientas de desarrollo
# fzf, git, node/volta, GPG, Claude Code (+ MCP servers + plugins), Zsh.
# Uso: bash install.sh

set -e

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
# fzf — keybindings y autocompletado
# Requiere que fzf ya esté instalado (Brewfile)
###############################################
info "Configurando fzf..."
"$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
success "fzf OK"

###############################################
# Git — configuración global vía symlink
# La config vive en config/git/config (linkeada por symlink.sh).
# Solo se configura aquí user.name/email que son datos personales.
###############################################
info "Configurando git..."

# Descomenta y personaliza:
# git config --global user.name "Tu Nombre"
# git config --global user.email "tu@email.com"

success "Git configurado OK"

###############################################
# Node.js vía volta
# Requiere que volta ya esté instalado (Brewfile)
###############################################
info "Instalando Node.js vía volta..."

volta install node@lts
volta install npm@latest
volta install pnpm@latest

success "Node.js OK"

###############################################
# GPG — configurar pinentry
# Requiere que gnupg y pinentry-mac ya estén instalados (Brewfile)
###############################################
info "Configurando GPG..."

mkdir -p ~/.gnupg
grep -qxF "pinentry-program $(brew --prefix)/bin/pinentry-mac" ~/.gnupg/gpg-agent.conf 2>/dev/null \
  || echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
chmod 700 ~/.gnupg

success "GPG configurado OK"

###############################################
# Claude Code — native installer (recomendado por Anthropic)
###############################################
info "Instalando Claude Code..."

curl -fsSL https://claude.ai/install.sh | bash
export PATH="$HOME/.claude/bin:$PATH"

success "Claude Code OK"

###############################################
# Claude Code — MCP Servers
# scope: user = disponibles en todos los proyectos
# Requiere que Claude Code ya esté instalado
###############################################
info "Configurando MCP Servers para Claude Code..."

# Context7 — documentación actualizada de librerías en tiempo real
claude mcp add -s user --transport http context7 https://mcp.context7.com/mcp

# PlanetScale — base de datos MySQL serverless
claude mcp add -s user --transport http planetscale https://mcp.pscale.dev/mcp/planetscale

# Sequential Thinking — razonamiento paso a paso para tareas complejas
claude mcp add -s user sequential-thinking npx @modelcontextprotocol/server-sequential-thinking

# Playwright — automatización de browser para testing
claude mcp add -s user playwright npx @playwright/mcp@latest

# Memory — memoria persistente entre sesiones
claude mcp add -s user memory npx @modelcontextprotocol/server-memory

# Codacy — análisis de calidad de código
claude mcp add -s user codacy npx @codacy/codacy-mcp

# Xcode — integración con Xcode (macOS)
claude mcp add -s user --transport stdio xcode -- xcrun mcpbridge

success "MCP Servers configurados OK"
warn "Revisa los MCP servers con: claude mcp list"
warn "PlanetScale y otros que requieren auth pedirán OAuth la primera vez que los uses."

###############################################
# Claude Code — Plugins
# El marketplace oficial (claude-plugins-official) está disponible
# automáticamente al instalar Claude Code, no necesita añadirse manualmente.
# scope: user = disponibles en todos los proyectos
# Requiere que Claude Code ya esté instalado y autenticado
###############################################
info "Instalando plugins de Claude Code..."

# LSP — inteligencia de código en tiempo real (jump to definition,
# find references, errores de tipos inline sin necesidad de compilar).
# Requiere: typescript-language-server en PATH (viene con volta/node)
claude plugin install typescript-lsp@claude-plugins-official --scope user

# Requiere: kotlin-lsp binary de JetBrains (ya instalado vía Homebrew)
claude plugin install kotlin-lsp@claude-plugins-official --scope user

# Requiere: sourcekit-lsp que viene incluido con Xcode CLT
claude plugin install swift-lsp@claude-plugins-official --scope user

# Context7 — documentación actualizada de librerías directamente en contexto.
# Evita que Claude use documentación desactualizada de su entrenamiento.
claude plugin install context7@claude-plugins-official --scope user

# Feature Dev — agente especializado en desarrollo de features completas,
# desde planificación hasta implementación y tests.
claude plugin install feature-dev@claude-plugins-official --scope user

# Frontend Design — agente especializado en UI/UX, componentes
# y buenas prácticas de diseño frontend.
claude plugin install frontend-design@claude-plugins-official --scope user

# Code Review — agente especializado en revisión de código,
# detecta bugs, problemas de seguridad y mejoras de rendimiento.
claude plugin install code-review@claude-plugins-official --scope user

success "Plugins de Claude Code instalados OK"
warn "Verifica los plugins instalados con: claude plugin list"

###############################################
# Zsh — Oh My Zsh + plugins + .zshrc
###############################################
info "Configurando Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || true

cat > ~/.zshrc << 'EOF'
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  macos
)

source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# mise — gestión de runtimes (Ruby, Python, etc.)
eval "$(mise activate zsh)"

# volta — gestión de Node.js
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Claude Code
export PATH="$HOME/.claude/bin:$PATH"

# 1Password SSH agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Aliases — eza reemplaza ls
alias ls="eza --icons"
alias ll="eza -lah --icons --git"
alias lt="eza --tree --icons --level=2"

# bat reemplaza cat
alias cat="bat"

# Aliases Git
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate --all"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# k9s — contextos de EKS
alias k9s-dev='k9s --context eks-dev'
alias k9s-stg='k9s --context eks-stg'
alias k9s-prod='k9s --context eks-prod'

EOF

success "Zsh configurado OK"

###############################################
# EKS — contextos de Kubernetes
# Requiere: awscli (Brewfile) y perfiles AWS configurados
###############################################
info "Configurando contextos de EKS..."

if ! command -v aws &>/dev/null; then
  warn "AWS CLI no encontrado en PATH — omitiendo contextos de EKS"
  warn "Instala con: brew install awscli"
elif aws sts get-caller-identity --profile dev &>/dev/null 2>&1; then
  aws eks update-kubeconfig --name eks-dev        --profile dev --alias eks-dev
  aws eks update-kubeconfig --name eks-staging    --profile stg --alias eks-stg
  aws eks update-kubeconfig --name eks-production --profile prod --alias eks-prod
  success "Contextos de EKS configurados OK"
else
  warn "Credenciales AWS no configuradas — omitiendo contextos de EKS"
  warn "Ejecuta manualmente después:"
  warn "  aws eks update-kubeconfig --name eks-dev        --profile dev --alias eks-dev"
  warn "  aws eks update-kubeconfig --name eks-staging    --profile stg --alias eks-stg"
  warn "  aws eks update-kubeconfig --name eks-production --profile prod --alias eks-prod"
fi
