#!/bin/sh

convert_branch_name() {
    name=$1
    echo ${name//./--}
}

reconvert_branch_name() {
    name=$1
    echo ${name//--/.}
}

currentBranch=$2
convertedCurrentBranch=`convert_branch_name $2`
superBranch=$3

if [[ $1 = "-a" ]]; then
    git config ztool.gitf.branch.$convertedCurrentBranch $superBranch
    git config gitflow.branch.develop $superBranch
elif [[ $1 = "-d" ]]; then
    #Delete the key-value of the given branch
    superBranch=`git config ztool.gitf.branch.$convertedCurrentBranch`
    git config gitflow.branch.develop $superBranch
    git config --unset ztool.gitf.branch.$convertedCurrentBranch
elif [[ $1 = "-p" ]]; then
    #Find super branch of the given branch
    git config ztool.gitf.branch.$convertedCurrentBranch
elif [[ $1 = "-b" ]]; then
    #Find sub branch of the given branch
    branches=`git config --list | grep "ztool.gitf.branch.*=$currentBranch" | cut -d '=' -f1 | cut -d '.' -f 4`
    for branch in ${branches[@]}; do
        echo `reconvert_branch_name $branch`
    done
else
    echo "Unkonw argument"
fi