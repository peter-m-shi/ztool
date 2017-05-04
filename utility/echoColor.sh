#!/bin/bash
#控制选项说明  
#\033[0m关闭所有属性  
#\033[1m设置高亮度  
#\033[4m下划线  
##字体色30-37 
#\033[显示方式;前景色;背景色m 
# echo  "\033[30m黑色字\033[0m"   -black 
# echo  "\033[31m红色字\033[0m"   -red
# echo  "\033[32m绿色字\033[0m"   -green
# echo  "\033[33m黄色字\033[0m"   -yellow
# echo  "\033[34m蓝色字\033[0m"   -blue
# echo  "\033[35m紫色字\033[0m"   -purple   暂时不用
# echo  "\033[36m天蓝字\033[0m"   -skyblue  暂时不用
# echo  "\033[37m白色字\033[0m"   -white


if [[ $# != 2 ]]; then
	echo "\033[31m Need Two Params: [color] [string] \033[0m"
	exit 1
fi



colorParam=$1
fontColor="33m"

if [[ -z $1 ]]; then
	# do nothing
	fontColor="33m"
else
	case "$colorParam" in
		-black)  
			fontColor="30m" 
			;;
		-red) 
			fontColor="31m"
			;;
		-green) 
			fontColor="32m"
			;;
		-yellow)
			fontColor="33m"
			;;
		-blue)
			fontColor="34m"
			;;
		-white)
			fontColor="37m"
			;;
	esac
fi

echo "\033[$fontColor$2\033[0m"






