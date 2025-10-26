  echo "Installing koushik's dotfiles"
  source ./functions/focus.sh
  
  # First, create a directory for your Zsh config files (if it doesn't exist)
  mkdir -p ~/.zsh
  
  for file in ./functions/{git_functions.sh,functions.sh}; do
    # Move your functions to a dedicated file in this directory
    cp "$file" ~/.zsh/"$(basename "$file")"
  
    # Add this line to your .zshrc to source the functions if not already present
    if ! grep -q "source ~/.zsh/$(basename "$file")" ~/.zshrc; then
        echo "Sourcing $(basename "$file")"
        echo "source ~/.zsh/$(basename "$file")" >> ~/.zshrc
    fi
  done;
  
  # Create ~/.config and ~/.config/git
  mkdir -p ~/.config/git
  
  # If repo contains ./config/git, install it into ~/.config/git
  if [ -d ./config/git ]; then
    echo "Installing git config files to ~/.config/git"
    for item in ./config/git/*; do
      [ -e "$item" ] || continue
      cp -R "$item" ~/.config/git/
    done
  fi
  
  CONFIG_FILE="$HOME/.config/git/config"
  
  # Validate ~/.config/git/config if present
  if [ -f "$CONFIG_FILE" ]; then
    if ! git config -f "$CONFIG_FILE" --list >/dev/null 2>&1; then
      echo "Warning: $CONFIG_FILE has invalid syntax."
      echo "Please fix it (INI-like format with [sections]) and re-run."
      # Avoid touching global config until user fixes the file
      exit 1
    fi
  fi
  
  # Ensure ~/.config/git/config is included in global git config (avoid following includes while checking)
  if [ -f "$CONFIG_FILE" ]; then
    if ! git config --global --no-includes --get-all include.path | grep -qx "$CONFIG_FILE"; then
      echo "Including ~/.config/git/config in global git config"
      git config --global --add include.path "$CONFIG_FILE"
    fi
  fi
