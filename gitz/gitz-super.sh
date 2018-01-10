#!/bin/sh

echo aaa

sh $GITZ_DIR/gitz-check.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo bbb

head=`cat .git/HEAD`
currentBranch=${head##*/}
superBranch=`sh $GITZ_DIR/gitf-nodes.sh -p ${currentBranch}`
userName=`git config --get user.name`

echo ccc

case $currentBranch in
    release-* | hotfix-* | feature-* | bugfix-* | develop-* )
        #release find sub,create a personal branch by user.name if not found
        if [[ -z $superBranch ]]; then
            echo can not found super branch.
            exit
        fi
        echo ----$superBranch
        git checkout $superBranch
        echo eee
        ;;

     * )
        echo operation on $currentBranch is forbidden.
        exit
        ;;
esac