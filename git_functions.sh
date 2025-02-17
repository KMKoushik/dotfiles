push () {
	local branch=$(git symbolic-ref --short HEAD)
	git push origin "$branch"
}

fpush () {
	push --force-with-lease
}

commit() {
	git add .
	git commit -m "$1"
}
