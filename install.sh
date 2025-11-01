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

  # Create ~/.config directory
  mkdir -p ~/.config
  
  # Install all config folders from ./config to ~/.config
  if [ -d ./config ]; then
    for config_dir in ./config/*; do
      [ -d "$config_dir" ] || continue
      config_name=$(basename "$config_dir")
      echo "Installing $config_name config files to ~/.config/$config_name"
      mkdir -p ~/.config/$config_name
      for item in "$config_dir"/*; do
        [ -e "$item" ] || continue
        cp -R "$item" ~/.config/$config_name/
      done
    done
  fi
