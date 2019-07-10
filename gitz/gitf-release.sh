#!/bin/sh

sh $GITZ_DIR/gitf-init.sh

if [ $2 = "go" ]; then

    count=`git branch | grep develop | wc -l`

    if [ $count -le 1 ]; then
        superBranch=develop
    else
        options="develop"
        echo "Please select the branch based on:"
        select superBranch in `git branch | grep -E "$options" | cut -d ' ' -f 2,3`
        do
            break
        done
    fi

    sh $GITZ_DIR/gitf-nodes.sh -a release-$1 $superBranch

    for branch in `git branch | grep -E release- | cut -d ' ' -f 2,3`; do
        git branch -m $branch temp-$branch
    done

    git flow release start $1
    if [ -n "`git remote -v`" ]; then
	    git push origin release-$1
	fi

    for branch in `git branch | grep -E temp-release- | cut -d ' ' -f 2,3`; do
        git branch -m $branch ${branch:5}
    done

elif [ $2 = "pr" ]; then
	sh $GITZ_DIR/gitz-request.sh master -f
	sh $GITZ_DIR/gitz-request.sh develop -f

    currentBranch=release-$1
    superBranch=`sh $GITZ_DIR/gitf-nodes.sh -p ${currentBranch}`
    if [ develop != $superBranch ]; then
        sh $GITZ_DIR/gitz-request.sh $superBranch -f
    fi

elif [ $2 = "ok" ]; then
    if [ -n "`git remote -v`" ]; then
    	git checkout master && git pull origin master
    	git checkout develop && git pull origin develop

        currentBranch=release-$1
        superBranch=`sh $GITZ_DIR/gitf-nodes.sh -p ${currentBranch}`
        if [ develop != $superBranch ]; then
            git checkout $superBranch && git pull origin $superBranch
        fi
	fi

    sh $GITZ_DIR/gitf-nodes.sh -d release-$1
    git flow release finish $1

    if [ -n "`git remote -v`" ]; then
	    git push --tags
	fi
else
    echo "Unkonw argument:$2"
fi