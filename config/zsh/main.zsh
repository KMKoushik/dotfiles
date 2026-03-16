export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [ -d "$ZSH" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

for file in "$HOME/.zsh/functions.sh" "$HOME/.zsh/git_functions.sh"; do
  [ -f "$file" ] && source "$file"
done

export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border=rounded --info=inline"
