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

