#!/bin/sh

currentBranch=$2
options=$3

if [[ $1 = "-a" ]]; then
    count=`git branch | grep develop | wc -l`

    if [[ $count -le 1 ]]; then
        baseBranch=develop
    else
        echo "Please select the branch based on:"
        select baseBranch in `ls .git/refs/heads | grep -E "$3"`
        do
            break
        done
    fi

    git config ztool.gitf.branch.$currentBranch $baseBranch
    git config gitflow.branch.develop $baseBranch

    git config gitflow.branch.develop
elif [[ $1 = "-d" ]]; then
    baseBranch=`git config --list | grep ztool.gitf.branch.$currentBranch | cut -d '=' -f 2`

    git config gitflow.branch.develop $baseBranch

    git config --unset ztool.gitf.branch.$currentBranch
else
    echo "unkonw argument"
fi