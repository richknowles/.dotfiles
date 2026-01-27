#!/bin/bash
# Dotfiles installation script
# Usage: ./install.sh [--all|--shell|--git|--vim|--help]

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Backup existing file/symlink and create new symlink
link_file() {
    local src="$1"
    local dst="$2"

    if [ ! -f "$src" ] && [ ! -d "$src" ]; then
        error "Source does not exist: $src"
        return 1
    fi

    # If destination exists, back it up
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        warn "Backed up existing $dst to $BACKUP_DIR/"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # Create symlink
    ln -s "$src" "$dst"
    success "Linked $src -> $dst"
}

# ============================================================================
# PLATFORM DETECTION
# ============================================================================
detect_platform() {
    case "$(uname -s)" in
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*)
            echo "macos"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

PLATFORM=$(detect_platform)
info "Detected platform: $PLATFORM"

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================
install_shell() {
    info "Installing shell configurations..."

    # Bash
    link_file "$DOTFILES_DIR/shell/bashrc" "$HOME/.bashrc"
    link_file "$DOTFILES_DIR/shell/bash_profile" "$HOME/.bash_profile"

    # Zsh (if installed)
    if command -v zsh &>/dev/null; then
        link_file "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"
    else
        warn "Zsh not installed, skipping zshrc"
    fi

    success "Shell configuration installed!"
}

install_git() {
    info "Installing git configurations..."

    link_file "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
    link_file "$DOTFILES_DIR/git/gitignore_global" "$HOME/.gitignore_global"

    echo ""
    warn "IMPORTANT: Update your git user info!"
    echo "  Run: git config --global user.name 'Your Name'"
    echo "  Run: git config --global user.email 'your.email@example.com'"
    echo ""

    success "Git configuration installed!"
}

install_vim() {
    info "Installing vim configuration..."

    link_file "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"

    # Create vim directories
    mkdir -p "$HOME/.vim/"{backup,swap,undo}

    success "Vim configuration installed!"
}

install_all() {
    info "Installing all configurations..."
    echo ""

    install_shell
    echo ""

    install_git
    echo ""

    install_vim
    echo ""

    success "All configurations installed!"
    echo ""
    info "Please restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
}

show_help() {
    cat << EOF
Dotfiles Installation Script

Usage: ./install.sh [OPTIONS]

Options:
    --all       Install all configurations (default)
    --shell     Install shell configurations only (bash, zsh)
    --git       Install git configuration only
    --vim       Install vim configuration only
    --help      Show this help message

Examples:
    ./install.sh            # Install everything
    ./install.sh --shell    # Only install shell configs
    ./install.sh --git      # Only install git config

Notes:
    - Existing files will be backed up to ~/.dotfiles_backup/
    - After installation, update git config with your name/email
    - Restart your terminal or source your shell config file

EOF
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   DOTFILES INSTALLER                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    case "${1:-}" in
        --shell)
            install_shell
            ;;
        --git)
            install_git
            ;;
        --vim)
            install_vim
            ;;
        --help|-h)
            show_help
            ;;
        --all|"")
            install_all
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
