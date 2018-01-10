#!/bin/sh

source $HOME/ztool/gitz/profile

sh $GITZ_DIR/gitz-check.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

head=`cat .git/HEAD`
user=`git config --get user.name`

branch=${head##*/}
prefix=`echo $branch | cut -d - -f1`

baseBranch=`sh $HOME/ztool/gitf/gitf-nodes.sh -p feature-$1`

if [[ -n "$1" ]]; then
    targetBranch=$1
elif [[ $user = $prefix ]]; then
    targetBranch=${branch%%+*}
    targetBranch=${targetBranch#*-}
elif [[ -n "$baseBranch" ]]; then
    targetBranch=$baseBranch
else
    echo "Neigher based nor personal branch can be found there."
    exit
fi

git pull origin $targetBranch
