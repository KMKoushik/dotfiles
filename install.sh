echo "Installing koushik's dotfiles"
source ./focus.sh

# First, create a directory for your Zsh config files (if it doesn't exist)
mkdir -p ~/.zsh

for file in ~/{git_functions,functions}.sh; do
  # Move your functions to a dedicated file in this directory
  cp "$(basename "$file")" ~/.zsh/"$(basename "$file")"

  # Add this line to your .zshrc to source the functions if not already present
  if ! grep -q "source ~/.zsh/$(basename "$file")" ~/.zshrc; then
      echo "Sourcing $(basename "$file")"
      echo "source ~/.zsh/$(basename "$file")" >> ~/.zshrc
  fi
done;



