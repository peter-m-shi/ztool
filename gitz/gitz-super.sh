#!/bin/sh

sh $GITZ_DIR/gitz-check.sh
if [ $? -ne 0 ]; then
    exit 1
fi

head=`cat .git/HEAD`
currentBranch=${head##*/}
superBranch=`sh $GITZ_DIR/gitf-nodes.sh -p ${currentBranch}`
userName=`git config --get user.name`

case $currentBranch in
    release-* | hotfix-* | feature-* | bugfix-* | develop-* | $userName-*)
        #release find sub,create a personal branch by user.name if not found
        if [ -z $superBranch ]; then
            echo No super branch can be found.
            exit
        fi
        git checkout $superBranch
        ;;

     * )
        echo operation on $currentBranch is forbidden.
        exit
        ;;
esac