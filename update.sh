#!/bin/bash

TOOLS_FOLDER="$HOME/ztool"
if [ -d $TOOLS_FOLDER ]; then
	old=$PWD

	if [[ $2 = "-s" ]]; then
		cd "$TOOLS_FOLDER" && git pull origin master && sh setup.sh $1
	else
		cd "$TOOLS_FOLDER" && git pull origin master
	fi

	cd $old
else
	str="ztool not installed at $HOME/"
	sh "./utility/echoColor.sh" "-red" "$str"
fi