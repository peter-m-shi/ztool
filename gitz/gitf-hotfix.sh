#!/bin/sh

sh $GITZ_DIR/gitf-init.sh

if [[ $2 = "go" ]]; then
    git flow hotfix start $1
    if [[ -n `git remote -v` ]]; then
	    git push origin hotfix-$1
	fi
elif [[ $2 = "pr" ]]; then
	sh $GITZ_DIR/gitz-request.sh master -f
	sh $GITZ_DIR/gitz-request.sh develop -f
elif [[ $2 = "ok" ]]; then
    git flow hotfix finish $1
else
    echo "unkonw argument:$2"
fi