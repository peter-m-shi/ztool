#!/bin/bash

source $HOME/ztool/dependency/profile
dependency_gem rubyzip
dependency_gem sigh

#安装命令补全
source $HOME/ztool/completion/profile
comp_install ipa _myipa