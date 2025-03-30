# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

function csvcount() {
	python -c "import csv, sys; print(sum(1 for row in csv.reader(sys.stdin)))" < "$1"
}