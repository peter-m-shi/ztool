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

git config --list | grep gitflow >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    echo "init config."
    git config gitflow.branch.master master
    git config gitflow.branch.develop develop
    git config gitflow.prefix.feature feature-
    git config gitflow.prefix.release release-
    git config gitflow.prefix.hotfix hotfix-
    git config gitflow.prefix.support support-
    git config gitflow.prefix.versiontag V
fi