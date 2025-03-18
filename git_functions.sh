push () {
	local branch=$(git symbolic-ref --short HEAD)
	git push origin "$branch"
}

p() {
	push
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

