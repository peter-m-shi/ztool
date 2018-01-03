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

echo $branch | grep -E "develop|master" >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Can not do this on master/develop branch."
    exit
fi

prefix=`echo $branch | cut -d - -f1`

if [[ -z "$1" ]]
then
	if [[ $user = $prefix ]]
	then
	    echo "Can not do this on your $user's own branch."
		exit
	fi
	base_branch=${branch}
else
	base_branch=$1
fi

user_branch="${user}-${base_branch}"

if [[ $base_branch = $user_branch ]]
then
    echo "Current branch is $user's own branch yet."
    exit
fi

git fetch origin

if [ -f ".git/refs/heads/${user_branch}" ]; then
    git checkout ${user_branch}
else
    if [ -f ".git/refs/remotes/origin/${user_branch}" ]; then
        git checkout -t origin/${user_branch}
    else
        git checkout -b ${base_branch}
        git push origin ${base_branch}

        git checkout -b ${user_branch}
        git push origin ${user_branch}
    fi
fi

git branch --set-upstream-to=origin/${base_branch}
