#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CONFIG_SOURCE='source "$HOME/.config/zsh/main.zsh"'

log() {
  printf "==> %s\n" "$1"
}

warn() {
  printf "==> warning: %s\n" "$1"
}

ensure_line_in_file() {
  local line="$1"
  local file="$2"

  touch "$file"

  if ! grep -Fqx "$line" "$file"; then
    printf "%s\n" "$line" >> "$file"
  fi
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_oh_my_zsh_plugin() {
  local repo_url="$1"
  local plugin_name="$2"
  local plugin_path="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"

  if [ -d "$plugin_path/.git" ]; then
    git -C "$plugin_path" pull --ff-only
    return
  fi

  if [ -d "$plugin_path" ]; then
    return
  fi

  git clone --depth=1 "$repo_url" "$plugin_path"
}

install_oh_my_zsh_plugins() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    warn "Oh My Zsh is unavailable; skipping plugin install"
    return
  fi

  log "Installing Oh My Zsh plugins"
  install_oh_my_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
  install_oh_my_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"
}

install_zsh_functions() {
  log "Installing custom shell functions"
  mkdir -p "$HOME/.zsh"

  for file in "$DOTFILES_DIR/functions/git_functions.sh" "$DOTFILES_DIR/functions/functions.sh"; do
    cp "$file" "$HOME/.zsh/$(basename "$file")"
  done
}

install_config_folders() {
  local config_root="$DOTFILES_DIR/config"
  if [ ! -d "$config_root" ]; then
    return
  fi

  log "Installing config files"
  mkdir -p "$HOME/.config"

  for config_dir in "$config_root"/*; do
    [ -d "$config_dir" ] || continue

    local config_name
    config_name="$(basename "$config_dir")"
    local destination_dir="$HOME/.config/$config_name"

    mkdir -p "$destination_dir"
    cp -R "$config_dir"/. "$destination_dir"/

    if [ "$config_name" = "opencode" ] && [ -f "$config_dir/opencode.json" ]; then
      local destination_json="$destination_dir/opencode.json"

      if [ -n "${EXA_KEY:-}" ]; then
        log "Injecting EXA_KEY into opencode config"
        sed "s#<exa_key>#${EXA_KEY}#g" "$config_dir/opencode.json" > "$destination_json"
      else
        warn "EXA_KEY not found in .env; leaving <exa_key> placeholder"
      fi
    fi
  done
}

configure_shell_startup() {
  log "Configuring ~/.zshrc"
  ensure_line_in_file "$ZSH_CONFIG_SOURCE" "$HOME/.zshrc"

  if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    warn "Default shell is not zsh. Run: chsh -s $(command -v zsh)"
  fi
}

main() {
  log "Installing koushik's dotfiles"

  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    warn "Do not run this installer with sudo/root (Homebrew will fail)."
    warn "Run as your normal user: bash install.sh"
    exit 1
  fi

  if [ -f "$DOTFILES_DIR/.env" ]; then
    # shellcheck disable=SC1091
    source "$DOTFILES_DIR/.env"
  fi

  install_oh_my_zsh
  install_oh_my_zsh_plugins
  install_zsh_functions
  install_config_folders
  configure_shell_startup

  if [ "${INSTALL_FOCUS:-0}" = "1" ]; then
    log "Installing focus utility"
    sudo bash "$DOTFILES_DIR/functions/focus.sh"
  fi

  log "Done. Restart your terminal or run: source ~/.zshrc"
}

main
