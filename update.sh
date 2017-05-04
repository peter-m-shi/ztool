#!/bin/bash

TOOLS_FOLDER="$HOME/ztool"
if [ -d $TOOLS_FOLDER ]; then
	old=$PWD
	cd "$TOOLS_FOLDER" && git pull origin master && sh setup.sh $1
	cd $old
else
	str="ztool not installed at $HOME/"
	sh "./utility/echoColor.sh" "-red" "$str"
fi