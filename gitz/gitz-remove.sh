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

user=`git config --get user.name`

branch=$1
prefix=`echo $branch | cut -d - -f1`

if [[ -z "$1" ]]
then
    echo "target branch parameter missed."
else
    if [[ $user = $prefix ]]
    then
        if [ -f ".git/refs/heads/${branch}" ]; then
            git branch -D ${branch}
        fi

        if [ -f ".git/refs/remotes/origin/${branch}" ]; then
            git push origin  :${branch}
        fi
    else
        echo "Remove operation is forbidden. "
        echo "Make sure the target branch is your $user's own branch."
    fi
fi