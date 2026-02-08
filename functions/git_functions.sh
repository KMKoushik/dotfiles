pull() {
    local branch=$(git symbolic-ref --short HEAD)
	git pull origin "$branch"
}

push () {
	if [ -n "$1" ]; then
		commit "$1"
	fi
	local branch=$(git symbolic-ref --short HEAD)
	git push origin "$branch"
}

p() {
	push "$1"
}

fpush () {
	local branch=$(git symbolic-ref --short HEAD)
	git push origin "$branch" --force-with-lease
}

fp() {
	fpush
}

commit() {
	git add .
	git commit -m "$1"
}

c() {
	commit "$1"
}

rebase() {
	git fetch
	local branch=${1:-main}
	git rebase origin/"$branch"
}

rb() {
	rebase "$1"
}


cpr() {
	git fetch origin pull/"$1"/head:"external-pr-$1"
	git switch external-pr-"$1"
}

branch() {
	local branch_name="$1"
	local date=$(date +%Y-%m-%d)
	local formatted_branch="km/$date-$branch_name"

	# Check for existing branches with similar name
	local existing_branch=$(git branch | grep "km/.*-$branch_name" | tr -d '[:space:]' | head -n1)

	if [ -n "$existing_branch" ]; then
		printf "Found existing branch '%s'. Use this instead? [Y/n] " "$existing_branch"
		read response
		response=${response:-Y}  # Default to Y if empty
		if [[ "$response" =~ ^[Yy]$ ]]; then
			git checkout "$existing_branch"
			return
		fi
	fi

	if ! git checkout -b "$formatted_branch"; then
		git checkout "$formatted_branch"
	fi
}

b() {
	branch "$1"
}

gw() {
	local command="$1"

	case "$command" in
		add)
			local name="$2"
			if [ -z "$name" ]; then
				echo "Usage: gw add <name>"
				return 1
			fi

			if [[ "$name" == */* ]]; then
				echo "gw: name cannot contain '/'. Use a simple name like feature-xyz"
				return 1
			fi

			if ! git check-ref-format --branch "$name" >/dev/null 2>&1; then
				echo "gw: invalid branch name: $name"
				return 1
			fi

			local common_git_dir
			common_git_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
				echo "gw: not inside a git repository"
				return 1
			}

			local repo_root
			repo_root=$(dirname "$common_git_dir")

			local source_root
			source_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
				echo "gw: unable to determine current worktree root"
				return 1
			}

			local project
			project=$(basename "$repo_root")
			local parent_dir
			parent_dir=$(dirname "$repo_root")
			local worktree_path
			worktree_path="$parent_dir/$project-$name"

			if [ -e "$worktree_path" ]; then
				echo "gw: worktree path already exists: $worktree_path"
				return 1
			fi

			if git show-ref --verify --quiet "refs/heads/$name"; then
				git worktree add -- "$worktree_path" "$name" || return 1
			else
				git worktree add -b "$name" -- "$worktree_path" || return 1
			fi

			local env_file
			while IFS= read -r -d '' env_file; do
				local relative_env_path
				relative_env_path=${env_file#"$source_root"/}

				local destination_env_path
				destination_env_path="$worktree_path/$relative_env_path"

				mkdir -p "$(dirname "$destination_env_path")" || return 1
				cp "$env_file" "$destination_env_path" || return 1
			done < <(find "$source_root" -type d -name .git -prune -o -type f -name '.env' -print0)

			cd "$worktree_path" || return 1
			;;

		rm)
			local name_or_path="$2"
			if [ -z "$name_or_path" ]; then
				echo "Usage: gw rm <name|path>"
				return 1
			fi

			local target_path="$name_or_path"
			if [[ "$name_or_path" != */* ]]; then
				local common_git_dir
				common_git_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
					echo "gw: not inside a git repository"
					return 1
				}

				local repo_root
				repo_root=$(dirname "$common_git_dir")

				local project
				project=$(basename "$repo_root")
				local parent_dir
				parent_dir=$(dirname "$repo_root")
				target_path="$parent_dir/$project-$name_or_path"
			fi

			git worktree remove -- "$target_path"
			;;

		ls)
			git worktree list
			;;

		go)
			local name_or_path="$2"

			local common_git_dir
			common_git_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
				echo "gw: not inside a git repository"
				return 1
			}

			local repo_root
			repo_root=$(dirname "$common_git_dir")

			if [ -z "$name_or_path" ]; then
				cd "$repo_root" || return 1
				return 0
			fi

			local target_path="$name_or_path"
			if [[ "$name_or_path" != */* ]]; then
				local worktree_line
				local current_worktree_path
				local matched_worktree_path
				while IFS= read -r worktree_line; do
					case "$worktree_line" in
						worktree\ *)
							current_worktree_path=${worktree_line#worktree }
							;;
						"branch refs/heads/$name_or_path")
							matched_worktree_path="$current_worktree_path"
							break
							;;
					esac
				done < <(git worktree list --porcelain)

				if [ -n "$matched_worktree_path" ]; then
					target_path="$matched_worktree_path"
				else
					local project
					project=$(basename "$repo_root")
					local parent_dir
					parent_dir=$(dirname "$repo_root")
					target_path="$parent_dir/$project-$name_or_path"
				fi
			fi

			if [ ! -d "$target_path" ]; then
				echo "gw: worktree directory does not exist: $target_path"
				return 1
			fi

			cd "$target_path" || return 1
			;;

		*)
			echo "Usage: gw <add|rm|ls|go> [name]"
			return 1
			;;
	esac
}
