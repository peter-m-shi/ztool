#!/bin/bash

TOOL_FOLDER="$HOME/ztool/shell"
USER_FOLDER="$HOME"

#判断shell环境
if [[ "$SHELL" == "/bin/zsh" ]]; then
	echo "[shell] zsh env has already been setuped."
else
	#安装oh my zsh
	sudo echo "[shell] install oh my zsh"
	curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

	echo "[shell] current shell: $SHELL"

	#切换shell环境
	echo "[shell] change shell to zsh"
	chsh -s /bin/zsh

	#配置zsh
	echo "[shell] config default zsh"
	cp "$USER_FOLDER/.zshrc" "$USER_FOLDER/.zshrc.bak"
	cp "$TOOL_FOLDER/zshrc" "$USER_FOLDER/.zshrc"

	#配置vim
	echo "[shell] config default vim"
	cp "$USER_FOLDER/.vimrc" "$USER_FOLDER/.vimrc.bak"
	cp "$TOOL_FOLDER/vimrc" "$USER_FOLDER/.vimrc"

	echo "[shell] zsh env config sucess"
fi