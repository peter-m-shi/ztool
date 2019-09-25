#!/bin/bash

ROOT_PROFILE="$HOME/.profile"
PG_PROFILE="$HOME/ztool/profile"

includeString(){
	echo "$1" | grep -q "$2" && return 0 || return 1
}

#判断shell环境
if includeString "$SHELL" "/bin/zsh"; then
	RC_FILE="$HOME/.zshrc"
elif includeString "$SHELL" "/bin/bash"; then
	RC_FILE="$HOME/.bashrc"
fi

addStringToFile(){
	ret=$(cat $2 | grep "$1")
	if [ "$ret" = "" ] ;then
		echo "
$1
	">>$2

	echo "[setup] \"$1\" ---> \"$2\"."
	fi
}

setupTool(){
	echo 'source '$1"/profile" $PG_PROFILE
	addStringToFile 'source '$1"/profile" $PG_PROFILE
	sh "$1/setup.sh"
	successString="$1 setup success !"
	sh "$HOME/ztool/utility/echoColor.sh" "-green" "$successString"
}

#在.profile里面添加source代码
addStringToFile "source $PG_PROFILE" $ROOT_PROFILE

#在.zshrc/.bashrc里面添加source代码
addStringToFile "source $ROOT_PROFILE" $RC_FILE

addStringToFile "env ZSH=$ZSH "'PGTOOLS_AUTO_CHECK=$PGTOOLS_AUTO_CHECK PGTOOLS_AUTO_HOURS=$PGTOOLS_AUTO_HOURS'" zsh -f $HOME/ztool/check_update.sh" $RC_FILE

if [ "$1" != "" ]; then
	if [ -d "$1" ]; then
		sh "$HOME/ztool/utility/echoColor.sh" "-yellow" "[$1]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
		setupTool $HOME/ztool/$1
	else
		failedString="$HOME/ztool/$1 not exsit!"
		sh "$HOME/ztool/utility/echoColor.sh" "-red" "$failedString"
	fi
else
	for file in $HOME/ztool/*
	do
	    if test -d $file
	    then
		    if [ "${file##*/}" != "shell" ] && [ "${file##*/}" != "image" ] && [ "${file##*/}" != "localizable" ]; then
	    		sh "$HOME/ztool/utility/echoColor.sh" "-yellow" "[${file##*/}]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
				setupTool $file
				echo 
			fi
	    fi
	done
fi


