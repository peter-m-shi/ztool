#!/bin/sh

source $HOME/ztool/dependency/profile
#安装依赖
dependency_gem atlassian-stash
dependency_brew git-flow-avh

#添加全局hooks模板
GIT_TEMPLATES_DIRECTORY="/Applications/GitHub.app/Contents/Resources/git/share/git-core/templates"
cp -r $HOME/ztool/gitz/commit-msg "$GIT_TEMPLATES_DIRECTORY/hooks"
cp -r $HOME/ztool/gitz/pre-commit "$GIT_TEMPLATES_DIRECTORY/hooks"
git config --global init.templatedir $GIT_TEMPLATES_DIRECTORY


#安装命令补全
source $HOME/ztool/completion/profile
comp_install gitz _mygit1
comp_install gitz _mygit2

