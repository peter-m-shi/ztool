#!/bin/sh

currentBranch=$2
superBranch=$3

if [[ $1 = "-a" ]]; then
    git config ztool.gitf.branch.$currentBranch $superBranch
    git config gitflow.branch.develop $superBranch
elif [[ $1 = "-d" ]]; then
    #Delete the key-value of the given branch
    superBranch=`git config ztool.gitf.branch.$currentBranch`
    git config gitflow.branch.develop $superBranch
    git config --unset ztool.gitf.branch.$currentBranch
elif [[ $1 = "-p" ]]; then
    #Find super branch of the given branch
    git config ztool.gitf.branch.$currentBranch
elif [[ $1 = "-b" ]]; then
    #Find sub branch of the given branch
    git config --list | grep "ztool.gitf.branch.*=$currentBranch" | cut -d '=' -f1 | cut -d '.' -f 4
else
    echo "unkonw argument"
fi