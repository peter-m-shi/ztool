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

if [[ $user = $prefix ]]
then
    superBranch=${branch%%+*}
    superBranch=${superBranch#*-}
else
    echo "Sync operation is forbidden. "
    echo "Make sure the target branch is your $user's own branch."
fi

if [ -f ".git/refs/heads/${superBranch}" ]; then
    git checkout ${superBranch}
else
    if [ -f ".git/refs/remotes/origin/${superBranch}" ]; then
        git checkout -t origin/${superBranch}
    else
    	echo "Super branch ${superBranch} not existed."
    fi
fi