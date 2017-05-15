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
    targetBranch=${branch%%+*}
    targetBranch=${targetBranch#*-}
else
    echo "Sync operation is forbidden. "
    echo "Make sure the target branch is your $user's own branch."
fi

git pull origin $targetBranch

git push origin $branch
