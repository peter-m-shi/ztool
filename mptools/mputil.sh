#!/bin/bash
if [ -f "$1" ]; then
	key=$2

	strings "$1" | grep "^\s*<" > ~/temp.plist

	/usr/libexec/PlistBuddy -c "Print $key" ~/temp.plist

	rm -f ~/temp.plist
else
	echo Error:参数错误[file:$1,key:$2]
fi

