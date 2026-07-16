#!/usr/bin/env bash
#
# install.sh — Bootstrap all dependencies for this Neovim configuration.
#
# Safe to re-run: every step checks for the tool before installing it.
# Supports macOS (Homebrew) and Debian/Ubuntu Linux (apt).
#
# The Neovim plugins themselves — and the LSP servers/formatters managed by
# Mason (pyright, ruff, lua_ls, harper_ls, prettier, stylua, eslint_d) — are
# installed automatically the first time you launch `nvim`. This script only
# installs the system-level runtimes and CLI tools those plugins rely on.

set -euo pipefail

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------
BOLD="$(tput bold 2>/dev/null || true)"
GREEN="$(tput setaf 2 2>/dev/null || true)"
YELLOW="$(tput setaf 3 2>/dev/null || true)"
RED="$(tput setaf 1 2>/dev/null || true)"
RESET="$(tput sgr0 2>/dev/null || true)"

info()  { printf '%s==>%s %s\n' "${BOLD}${GREEN}" "${RESET}" "$*"; }
warn()  { printf '%s==>%s %s\n' "${BOLD}${YELLOW}" "${RESET}" "$*"; }
error() { printf '%s==>%s %s\n' "${BOLD}${RED}" "${RESET}" "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

OS="$(uname -s)"

# ----------------------------------------------------------------------------
# Package manager detection
# ----------------------------------------------------------------------------
PKG=""
case "$OS" in
  Darwin) PKG="brew" ;;
  Linux)
    if have apt-get; then
      PKG="apt"
    else
      error "Unsupported Linux distribution: this script only automates apt-based systems."
      error "Install the tools listed in README.md manually, then re-run to verify."
      exit 1
    fi
    ;;
  *)
    error "Unsupported OS: $OS. See README.md for manual instructions."
    exit 1
    ;;
esac

# ----------------------------------------------------------------------------
# Bootstrap the package manager itself
# ----------------------------------------------------------------------------
if [ "$PKG" = "brew" ]; then
  if ! have brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Make brew available in this shell (Apple Silicon vs Intel paths).
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    info "Homebrew already installed."
  fi
elif [ "$PKG" = "apt" ]; then
  info "Updating apt package index..."
  sudo apt-get update -y
fi

# ----------------------------------------------------------------------------
# Package name maps (tool -> package on each manager)
# ----------------------------------------------------------------------------
brew_install() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    info "$formula already installed."
  else
    info "Installing $formula..."
    brew install "$formula"
  fi
}

apt_install() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    info "$pkg already installed."
  else
    info "Installing $pkg..."
    sudo apt-get install -y "$pkg"
  fi
}

# ----------------------------------------------------------------------------
# Core dependencies
# ----------------------------------------------------------------------------
# neovim   : the editor (needs >= 0.11; this config uses vim.lsp.config + 0.12 APIs)
# git      : lazy.nvim bootstrap + Snacks git pickers
# ripgrep  : Snacks grep / live-grep pickers
# fd       : file finder + Python venv picker (<leader>cv)
# lazygit  : Snacks lazygit UI (<leader>gg)
# gh       : GitHub issue/PR pickers (<leader>gi, <leader>gp)
# node/npm : runtime for Mason-managed LSPs (pyright, eslint_d, prettier)
# yarn     : builds markdown-preview.nvim
# python3  : pyright/ruff interpreter resolution
# build    : C compiler + make for plugins that compile native bits

if [ "$PKG" = "brew" ]; then
  brew_install neovim
  brew_install git
  brew_install ripgrep
  brew_install fd
  brew_install lazygit
  brew_install gh
  brew_install node
  brew_install yarn
  brew_install python3
  # curl + make ship with macOS / Xcode CLT; ensure Xcode CLT is present.
  if ! xcode-select -p >/dev/null 2>&1; then
    info "Installing Xcode Command Line Tools (compiler + make)..."
    xcode-select --install || true
  else
    info "Xcode Command Line Tools already installed."
  fi
elif [ "$PKG" = "apt" ]; then
  # Ubuntu's apt neovim is often too old; use the unstable PPA for >= 0.11.
  if ! have nvim || ! nvim --version | head -1 | grep -qE 'v0\.(1[1-9]|[2-9][0-9])'; then
    info "Adding Neovim unstable PPA for an up-to-date build..."
    apt_install software-properties-common
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update -y
  fi
  apt_install neovim
  apt_install git
  apt_install ripgrep
  apt_install fd-find      # binary is `fdfind` on Debian; see note below
  apt_install curl
  apt_install build-essential
  apt_install python3
  apt_install python3-pip
  apt_install nodejs
  apt_install npm

  # GitHub CLI (gh) is not in the default repos — add its apt source.
  if ! have gh; then
    info "Adding GitHub CLI apt repository..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update -y
    apt_install gh
  else
    info "gh already installed."
  fi

  # lazygit is not packaged — install the latest release binary.
  if ! have lazygit; then
    info "Installing lazygit..."
    LAZYGIT_VERSION="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep -Po '"tag_name": *"v\K[^"]*')"
    curl -fsSLo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
  else
    info "lazygit already installed."
  fi

  # yarn via npm (classic) if not present.
  if ! have yarn; then
    info "Installing yarn (classic) via npm..."
    sudo npm install -g yarn
  else
    info "yarn already installed."
  fi

  # Debian names the fd binary `fdfind`; symlink it to `fd` for the venv picker.
  if have fdfind && ! have fd; then
    info "Symlinking fdfind -> fd..."
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
fi

# ----------------------------------------------------------------------------
# Nerd Font (required for the icons used across Snacks, lualine, blink, LSP)
# ----------------------------------------------------------------------------
if [ "$PKG" = "brew" ]; then
  if brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
    info "JetBrainsMono Nerd Font already installed."
  else
    info "Installing JetBrainsMono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font || \
      warn "Could not install the Nerd Font cask; install one manually from https://www.nerdfonts.com and set it in your terminal."
  fi
else
  warn "Install a Nerd Font manually (https://www.nerdfonts.com) and select it in your terminal for icons to render."
fi

# ----------------------------------------------------------------------------
# Verify & headline the result
# ----------------------------------------------------------------------------
info "Verifying installed tools..."
MISSING=()
for tool in nvim git rg fd lazygit gh node npm python3; do
  if have "$tool"; then
    printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$tool"
  else
    printf '  %s✗%s %s\n' "$RED" "$RESET" "$tool"
    MISSING+=("$tool")
  fi
done

if [ "${#MISSING[@]}" -gt 0 ]; then
  warn "Some tools are missing: ${MISSING[*]}"
  warn "Re-run this script or install them manually (see README.md)."
fi

echo
info "System dependencies are ready."
info "Launch ${BOLD}nvim${RESET} — lazy.nvim will bootstrap and Mason will install the LSP servers on first run."
info "Run ${BOLD}:checkhealth${RESET} inside Neovim to confirm everything resolves."
