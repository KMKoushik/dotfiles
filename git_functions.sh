push () {
	local branch=$(git symbolic-ref --short HEAD)
	git push origin "$branch"
}

fpush () {
	push --force-with-lease
}

