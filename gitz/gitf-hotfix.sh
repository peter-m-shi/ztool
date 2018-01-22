#!/bin/sh

sh $GITZ_DIR/gitf-init.sh

if [ $2 = "go" ]; then
    git flow hotfix start $1
    if [ -n `git remote -v` ]; then
	    git push origin hotfix-$1
	fi
elif [ $2 = "pr" ]; then
	sh $GITZ_DIR/gitz-request.sh master -f
	sh $GITZ_DIR/gitz-request.sh develop -f
elif [ $2 = "ok" ]; then
    if [ -n `git remote -v` ]; then
	    git checkout master && git pull origin master
	    git checkout develop && git pull origin develop
	    git checkout hotfix-$1 && git pull origin hotfix-$1
	fi
	
	sh $GITZ_DIR/gitf-nodes.sh -d hotfix-$1
    git flow hotfix finish $1
else
    echo "Unkonw argument:$2"
fi