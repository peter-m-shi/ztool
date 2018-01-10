#!/bin/sh

sh $GITZ_DIR/gitz-check.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

head=`cat .git/HEAD`
user=`git config --get user.name`

branch=${head##*/}
prefix=`echo $branch | cut -d - -f1`
origin=`git ls-remote --get-url origin`

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

msg="${targetBranch} pull-request"
desc=`git log $branch ^origin/$targetBranch --pretty=oneline --abbrev-commit --no-merges`

if [[ "$desc" == "" ]]; then
    desc="None"
fi

result=$(echo $origin | grep "github.com")
if [[ "$result" != "" ]]
then
    echo "hub pull-request -o -m \"$msg\" -b $branch -h $targetBranch" > pr.sh
else
    echo "stash pull-request -o --title \"$msg\" --description \"$desc\" $branch $targetBranch --trace" > pr.sh
fi

sh pr.sh
rm -rf pr.sh