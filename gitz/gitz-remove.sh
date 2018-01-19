#!/bin/sh

sh $GITZ_DIR/gitz-check.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

user=`git config --get user.name`

branch=$1
prefix=`echo $branch | cut -d - -f1`

if [[ "$2" == "-f" ]]; then
    user=$prefix
fi

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

        sh $GITZ_DIR/gitf-nodes.sh -d $1
    else
        echo "Remove operation is forbidden. "
        echo "Make sure the target branch is your $user's own branch."
    fi
fi
