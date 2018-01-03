#!/bin/sh

export GITF_DIR=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")

# enable debug mode
if [ "$DEBUG" = "ture" ]; then
	set -x
fi

usage() {
	echo "usage: gitf  <subcommand>"
	echo
	echo "Available subcommands are:"
	echo "   feature  manage feature flow. use [go] to start and [ok] to finish."
	echo "   release  manage release flow. use [go] to start and [ok] to finish."
	echo "   bugfix  manage bugfix flow. use [go] to start and [ok] to finish."
	echo "   hotfix  manage hotfix flow. use [go] to start and [ok] to finish."
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

	if [ ! -e "$GITF_DIR/gitf-$SUBCOMMAND.sh" ]; then
		usage
		exit 1
	fi

	# run command
	sh "$GITF_DIR/gitf-$SUBCOMMAND.sh" $*
	FLAGS_PARENT="gitf $SUBCOMMAND"
}

main "$@"