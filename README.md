
<font color="#450cc4" size = "3px">	

##How to install

use the follow command to install all the tools.

	git clone https://github.com/peter-m-shi/ztool.git $HOME/ztool;sh $HOME/ztool/setup.sh

use the foloow command to install a special tool.

	sh setup.sh mptools
	
##How to use tools

#gitz 

[TOC]

##安装##

打开终端，执行如下命令：

>$ git clone https://github.com/peter-m-shi/ztool.git $HOME/ztool;sh $HOME/ztool/setup.sh



##gitf工具##

gitf工具包含了如下几个命令：



**gif feature**（亦可简写为**ff**）



功能：



（1）从develop拉取feature分支，开始工作；

（2）完成开发，合并回原分支.



示例：



>$ ==ff== function1 ==go==



>$ ==ff== function1 ==ok==



Notes:

（1）根据提示选择从develop，develop-A，develop-B拉取分支。

（2）上述命令中的"function1"为feature分支名。





**gif release**（亦可简写为**fr**）



功能：



（1）从develop拉取release分支，开始集成测试；

（2）完成测试，合并到master分支（并打tag）和develop分支。



示例：



>$ ==fr== 7.0.0 ==go==

>$ ==fr== 7.0.0 ==ok==



Notes：上述命令中的"7.0.0"为待发布版本号。



**gif bugfix**（亦可简写为**fb**）



功能：



（1）从release拉取bugfix分支，修复bug；

（2）完成修复，合并回release分支。



示例：



> $ ==fb== MGV6-1234 ==go==



> $ ==fb== MGV6-1234 ==ok==



Notes：上述命令中的“MGV6-1234”为BugID.



**gif hotfix**（亦可简写为**fh**）



功能：



（1）从master拉取hotfix分支，开始修复线上bug；

（2）完成修复，合并回master分支。



示例：



>$ ==fh== crash ==go==



>$ ==fh== crash ==ok==





##gitz工具##

gitz工具集的使用场景：多人协作于同一分支（协作开发同一feature、sub-feature，协作修改同一bugfix，hotfix）



**gitz pull**



从当前personal分支的上级分支拉取更新



**gitz push**



向当前personal分支的上级分支合并修改



**gitz request**



直接在命令行页面提起pull request，不需要打开Bitbucket创建pull request，提请成功会出现弹窗提示。



**git sub**



从上级分支切换到personal分支



**git super**



从当前的personal分支切换到上级分支



**git remove**



从本地和远程移除名为XXX的分支




#localizable

Use locinit to init configrure in  localizable folder
	
	locinit

Use loc2s to convert xls to strings file
	
	loc2s

Use loc2x to convert strings file to xls
	
	loc2x
	
Use lochelp to show help info
	
	lochelp
	
#package

Change xcode project configuration by gien config file

	pkg -env dev.cfg
	
Build xcode project

	pkg -build

Build xcode project by Debug or Release

	pkg -build Debug
	
Clean xcode project

	pkg -clean
	
Make ipa file

	pkg -make

Batch make ipa file

	pkg -bat

Env configuration
	
	[Use ':' to define Action && Object]
	|							Action							|		Object			  |
	|			Key 		  |flag|			Value 			|subObj|		Obj 	  |
	GCC_PREPROCESSOR_DEFINITIONS++DEBUG=1 INHOUCE_LOC=0 OTHER=1:Widget<-Project.xcodeproj

	Action flag:
	[>>]
	Use 'key>>value' Set key-value in Action: 
	CFBundleIdentifier>>com.company.product

	[++]
	Use 'key++value' add key-value in Action:
	GCC_PREPROCESSOR_DEFINITIONS++A=1 B=3 C=3

	[Object]
	Use 'subObj<-Obj' define target of project:
	Widget<-Project.xcodeproj

	[Object Support Type]
	.plist
	.entitlements
	.xcodeproj
	.file(only format)

Make configuration

1、Defined by action
	
filed|description|remark
:---------------|:---------------	|:---------------
Build Mode| argument used in 'pkg -b [debug/release]'
Build Time| the time when build/make | %Y%m%d%H%M%S

2、Defined in Info.plist

filed|description|remark
:---------------|:---------------	|:---------------
Product Name|Bundle name|String type, etc. "Product"
Product Version|Bundle versions string, short|String type, etc. "6.2.0"
Build Version|Bundle version | Interger type, etc. 620

3、Custom filed defined in Info.plist
	
filed|description|remark
:---------------|:---------------	|:---------------
Product Stage|APP_STAGE|String type, etc. "stage 1"
Git Version|APP_GIT_REVISION
Channel|APP_CHANNEL|String type, etc. "91"
Environment|APP_ENV|Interger type,0-DevEnv 1-TestEnv 2-GreyEnv 3-ReleaseEnv
Custom|APP_CUSTOM|String type, etc. "custom filed"

4、Fields prioprity in ipa name:
	
	{Product Name}\_{Product Version}\_{Build Mode}\_{Product Stage}\_{Build Time}\_{Channel}\_{Environment}\_{Custom}\_{Build Version}\_{Git Version}

5、Enable build version auto increase 

	set CFBundleVersionAutoIncrease=1 in Info.plist

	
#mptools

List all the provisionprofile file

	mplist
	
Remove all the provisionprofile file

	mpclean
	
Install provisionprofile file

	mpinstall test.provisionprofile
	
Install provisionprofile folder

	mpinstall ./provisionprofileFolder

#utility

Quik start project by xcode

	xx
	
Quik start project by appcode

	aa
	
#shell

change shell to zsh

	sh setup.sh
   