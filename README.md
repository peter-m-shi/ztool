
<font color="#450cc4" size = "3px">	

##How to install

use the follow command to install all the tools.

	git clone https://github.com/peter-m-shi/ztool.git $HOME/ztool;sh $HOME/ztool/setup.sh

use the foloow command to install a special tool.

	sh setup.sh mptools
	
##How to use tools

#git
	usage: gitz  <subcommand>"
	Available subcommands are:
	   sub      switch/create sub personal branch base on the given branch, base on current branch if no params.
	   super   switch to personal's super branch of current branch"
	   sync   sync from the given branch, from current branch if no params.
	   request   create a pull request base on current personal's branch.
	   remove   remove both of the local and remote branch of given name.
	Try 'gitz help <subcommand> help' for details.

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
   