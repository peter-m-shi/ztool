#!/bin/sh

sh $GITZ_DIR/gitz-check.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

head=`cat .git/HEAD`
user=`git config --get user.name`

branch=${head##*/}
prefix=`echo $branch | cut -d - -f1`

baseBranch=`sh $GITZ_DIR/gitf-nodes.sh -p feature-$1`

if [[ $user = $prefix ]]
then
    targetBranch=${branch%%+*}
    targetBranch=${targetBranch#*-}
elif [[ -n "$baseBranch" ]]; then
    targetBranch=$baseBranch
else
    echo "Neigher based nor personal branch can be found there."
    exit
fi

git pull origin $targetBranch

git push origin $branch
