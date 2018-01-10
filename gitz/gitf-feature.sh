#!/bin/sh

sh $GITZ_DIR/gitf-init.sh

if [[ $2 = "go" ]]; then
	#Append the key-value of the given branch
    count=`git branch | grep develop | wc -l`

    if [[ $count -le 1 ]]; then
        superBranch=develop
    else
		options="develop"
        echo "Please select the branch based on:"
        select superBranch in `git branch | grep -E "$options" | cut -d ' ' -f 2,3`
        do
            break
        done
    fi

    sh $GITZ_DIR/gitf-nodes.sh -a feature-$1 $superBranch
    git flow feature start $1
    if [[ -n `git remote -v` ]]; then
        git push origin feature-$1
    fi
elif [[ $2 = "pr" ]]; then
    targetBranch=`sh $GITZ_DIR/gitf-nodes.sh -p feature-$1`
    sh $GITZ_DIR/gitz-request.sh $targetBranch -f
elif [[ $2 = "ok" ]]; then
    sh $GITZ_DIR/gitf-nodes.sh -d feature-$1
    git flow feature finish $1
else
    echo "unkonw argument:$2"
fi