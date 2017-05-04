
MPTOOLS_PATH="$HOME/ztool/mptools/"
TARGET_PATH="$HOME"/'Library/MobileDevice/Provisioning Profiles'

#修复证书名称是一串数字和字母额情况。
for file in "$TARGET_PATH"/*.mobileprovision
	do

	 	provision_name=$(sh $MPTOOLS_PATH/mputil.sh "$file" Name)
		

		provisionfile_path="$TARGET_PATH/$provision_name.mobileprovision"

		if [[ $file != $provisionfile_path ]]; then
			mv "$file" "$provisionfile_path"
			echo "changeName: ${file##*/}  to: $provision_name.mobileprovision"
		fi

done