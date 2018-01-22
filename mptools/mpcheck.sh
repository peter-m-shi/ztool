
MPTOOLS_PATH="$HOME/ztool/mptools/"
TARGET_PATH="$HOME"/'Library/MobileDevice/Provisioning Profiles/'

_printProvision()
{
	iphoneID=$1
	#iphone id  长度为40位
	iphoneIdentifierLength=${#iphoneID}

	if [ $iphoneIdentifierLength -eq 40 ]; then
		echo "------------- provision contain device -------------"
		#遍历证书
		for file in "$TARGET_PATH"/*.mobileprovision
			do
			  #搜索是否存在手机的序列号
			  result=$(sh $MPTOOLS_PATH/mputil.sh "$file" | grep "$1")
			  #不为空证明搜索到了，存在于这个证书里面
			  if [ -n "$result" ]; then
			  	   #打印证书名称。这里去除全路径。保留证书名称
			  		echo ${file##*/}
			  fi
		done
	else

		sh "$HOME/ztool/utility/echoColor.sh" "-red" "Error: illegal iphone identifier length"

	fi
}


if [ -z $1 ]; then
	serial_Number=`ioreg -p IOUSB -n "iPhone" | grep "USB Serial Number" | awk -F '=' '{print $2}' | awk -F '"' '{print $2}'`

	_printProvision $serial_Number

else
	_printProvision $1
fi









