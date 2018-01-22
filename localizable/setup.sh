#!/bin/bash
RET="failed"

source $HOME/ztool/dependency/profile

_FixBuilderFile(){
	if [[ -d "$1" ]]; then
		SYS_BUILDER_FILE=$(find "$1" -name "builder.rb" | grep woz)
		if [[ -n $SYS_BUILDER_FILE ]]; then
			echo "[fix-bug]: cp builder.rb to $SYS_BUILDER_FILE"
			builderFile="$HOME/ztool/localizable/builder.rb"

			if [[ "$(md5 $builderFile | cut -d "=" -f2)" != "$(md5 $SYS_BUILDER_FILE | cut -d "=" -f2)" ]]; then
				sudo cp $builderFile $SYS_BUILDER_FILE
			fi
			RET="success"
		fi
	fi
}

#是否安装了woz
dependency_gem woz
_FixBuilderFile "/Library/Ruby/Gems/"
_FixBuilderFile "$HOME/.rvm/rubies/"
_FixBuilderFile "/usr/local/lib/ruby/"
_FixBuilderFile "/usr/local/Cellar/ruby/"

echo "woz installed $RET!"