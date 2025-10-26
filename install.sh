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
