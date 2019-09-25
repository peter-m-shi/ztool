#!/bin/bash
MPTOOLS_PATH="$HOME/ztool/mptools/"
TARGET_PATH="$HOME"/'Library/MobileDevice/Provisioning Profiles/'

_install(){
	#获取当前mobileprovision identifier
	identifier=$(sh $MPTOOLS_PATH/mputil.sh "$1" Entitlements:application-identifier)

	certificate=$(sh $MPTOOLS_PATH/mputil.sh "$1" DeveloperCertificates | grep "iPhone Developer")

	#查找是否已有相同identifier的mobileprovision

	for file in "$TARGET_PATH"/*.mobileprovision
	do
		#if [ $file != "$TARGET_PATH"/*.mobileprovision ]; then
			ret_certificate=$(sh $MPTOOLS_PATH/mputil.sh "$file" DeveloperCertificates | grep "iPhone Developer")
			ret_identifier=$(sh $MPTOOLS_PATH/mputil.sh "$file" Entitlements:application-identifier)
			
		  	if [ "$ret_identifier" == "$identifier" -a "$ret_certificate" == "$certificate" ]; then
		  		#statements
		  		echo [删除]:$file[$ret]
		  		rm -f "$file"
		  	fi
		#fi
	done

	cp -f "$1" "$TARGET_PATH"
	echo [安装]:$1
	echo '      '$identifier
}

if [ -f "$1" ]; then
  	_install "$1"

  	sh $MPTOOLS_PATH/mplist.sh
elif [ -d "$1" ]; then
	for file in "$1"/*.mobileprovision
	do
		if [ $file != "./*.mobileprovision" ]; then
			_install "$file"
			echo 
		fi
	done

	sh $MPTOOLS_PATH/mplist.sh
else
	echo Error:参数错误[file/folder:$1]
	echo mpinstall [file or folder]            
	echo "# install one or more mobileprovision files to \"/Library/MobileDevice/Provisioning\ Profiles\""
	
fi