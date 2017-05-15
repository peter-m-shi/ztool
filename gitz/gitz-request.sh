#!/bin/sh

now_pwd=`pwd`
while [[ ! -d ".git" ]]
do
    cd ..
    if [[ `pwd` = '/' ]]
    then
        echo 'Not a git repository (or in children of the root directory): .git'
        cd ${now_pwd}
        exit
    fi
done

head=`cat .git/HEAD`
user=`git config --get user.name`

branch=${head##*/}
prefix=`echo $branch | cut -d - -f1`
origin=`git ls-remote --get-url origin`

if [[ $user = $prefix ]]
then
    if [[ -z "$1" ]]
    then
        targetBranch=${branch%%+*}
        targetBranch=${targetBranch#*-}
    else
        targetBranch=$1
    fi

    msg="${targetBranch} pull-request"
    desc=`git log $branch ^origin/$targetBranch --pretty=oneline --abbrev-commit --no-merges`

    result=$(echo $origin | grep "github.com")
    if [[ "$result" != "" ]]
    then
        echo "hub pull-request -o -m "$msg" -b $branch -h $targetBranch" > pr.sh
    else
        echo "stash pull-request -o --title \"$msg\" --description \"$desc\" $branch $targetBranch --trace" > pr.sh
    fi
    sh pr.sh
    rm -rf pr.sh
else
    echo "Sync operation is forbidden. "
    echo "Make sure the target branch is your $user's own branch."
fi