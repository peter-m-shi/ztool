#!/bin/bash

#判断shell环境
if [ "$SHELL" == "/bin/zsh" ]; then
	#添加命令补全
	COMP_FILE="$HOME/ztool/$1/$2"
	ZSH_VERSION=$(zsh --version | cut -d " " -f2)
	TARGET_FILE="/usr/local/share/zsh/site-functions/$2"

	if [ "$(md5 $COMP_FILE | cut -d "=" -f2)" != "$(md5 $TARGET_FILE | cut -d "=" -f2)" ]; then
		sudo cp "$COMP_FILE" "$TARGET_FILE"
	fi

	 str="$1 completion installed success!"

	 pwd
	 sh "$HOME/ztool/utility/echoColor.sh" "-green" "$str"
fi