#!/bin/sh

source $HOME/ztool/gitz/profile

sh $GITZ_DIR/gitz-check.sh
if [ $? -ne 0 ]; then
    exit 1
fi

head=`cat .git/HEAD`
user=`git config --get user.name`

branch=${head##*/}
prefix=`echo $branch | cut -d - -f1`

baseBranch=`sh $GITZ_DIR/gitf-nodes.sh -p $branch`

if [ -n "$1" ]; then
    targetBranch=$1
elif [ $user = $prefix ]; then
    targetBranch=${branch%%+*}
    targetBranch=${targetBranch#*-}
elif [ -n "$baseBranch" ]; then
    targetBranch=$baseBranch
fi

if [ -n "`git remote -v`" ]; then
	if [ -n $targetBranch ]; then
		git pull origin $targetBranch
	fi
else
	echo "No remote url can be found."
fi

