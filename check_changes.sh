#!/usr/bin/env zsh

TOOLS_FOLDER="$HOME/ztool"

old=$PWD

cd "$TOOLS_FOLDER"

origin=`git ls-remote --get-url origin`
git fetch $origin master --quiet >/dev/null 2>&1

if [ $? -eq 0 ]; then
	#git log --oneline FETCH_HEAD ^master>$TOOLS_FOLDER/.tools-changes
	git log --pretty=format:"%h [%an] : %s" -n 1 FETCH_HEAD ^master>$TOOLS_FOLDER/.tools-changes
fi

cd $old