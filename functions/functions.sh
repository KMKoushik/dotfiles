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
	python -c "import csv, sys; csv.field_size_limit(sys.maxsize); print(sum(1 for row in csv.reader(sys.stdin)))" < "$1"
}


function cdx() {
	codex -m gpt-5-codex
}

function killport() {
	if [ $# -eq 0 ]; then
		echo "Usage: killport <port>"
		return 1
	fi
	lsof -ti:$1 | xargs kill -9
}