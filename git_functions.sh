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
	if ! git checkout -b "$branch_name"; then
		git checkout "$branch_name"
	fi
}

b() {
	branch "$1"
}

