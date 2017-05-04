#!/bin/bash
source $HOME/ztool/dependency/profile

#是否安装了git
dependency_gem git

#是否安装了xcodeproj 1.2.0
dependency_gem xcodeproj 1.2.0

#是否安装了xcpretty
dependency_gem xcpretty

#安装命令补全
source $HOME/ztool/completion/profile
comp_install package _mypkg