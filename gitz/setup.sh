#!/bin/sh

source $HOME/ztool/dependency/profile
#安装依赖
dependency_gem atlassian-stash
if [ `uname` -eq "Darwin" ]; then
	dependency_brew git-flow-avh

	#添加全局hooks模板
	GIT_TEMPLATES_DIRECTORY="/Applications/GitHub.app/Contents/Resources/git/share/git-core/templates"
	cp -r $HOME/ztool/gitz/commit-msg "$GIT_TEMPLATES_DIRECTORY/hooks"
	cp -r $HOME/ztool/gitz/pre-commit "$GIT_TEMPLATES_DIRECTORY/hooks"
	git config --global init.templatedir $GIT_TEMPLATES_DIRECTORY
else
	curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
	chmod +x gitflow-installer.sh
	sudo ./gitflow-installer.sh
fi

#安装命令补全
source $HOME/ztool/completion/profile
comp_install gitz _mygit1
comp_install gitz _mygit2

