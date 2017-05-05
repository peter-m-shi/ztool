#!/bin/sh

export GITZ_DIR=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")

# enable debug mode
# if [ "$DEBUG" = "ture" ]; then
	set -x
# fi

usage() {
	echo "usage: gitz  <subcommand>"
	echo
	echo "Available subcommands are:"
	echo "   sub      switch/create sub personal branch base on the given branch, base on current branch if no params."
	echo "   super   switch to personal's super branch of current branch"
	echo "   sync   sync from the given branch, from current branch if no params."
	echo "   request   create a pull request base on current personal's branch."
	echo "   remove   remove both of the local and remote branch of given name."
	echo
	echo "Try 'gitz help <subcommand> help' for details."
}

main() {
	if [ $# -lt 0 ]; then
		usage
		exit 1
	fi

	export POSIXLY_CORRECT=1

	# sanity checks
	SUBCOMMAND="$1"; shift

	if [ ! -e "$GITZ_DIR/gitz-$SUBCOMMAND.sh" ]; then
		usage
		exit 1
	fi

	# run command
	sh "$GITZ_DIR/gitz-$SUBCOMMAND.sh" $*
	FLAGS_PARENT="gitz $SUBCOMMAND"
}

main "$@"