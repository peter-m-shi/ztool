#!/bin/sh

sh $GITZ_DIR/gitz-check.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

head=`cat .git/HEAD`
currentBranch=${head##*/}
userName=`git config --get user.name`

#Append the key-value of the given branch
count=`sh $GITZ_DIR/gitf-nodes.sh -b ${currentBranch} | wc -l`

if [[ $count -le 1 ]]; then
    subBranch=`sh $GITZ_DIR/gitf-nodes.sh -b ${currentBranch}`
else
    options="develop"
    echo "Please select the branch based on:"
    select subBranch in `sh $GITZ_DIR/gitf-nodes.sh -b ${currentBranch}`
    do
        break
    done
fi

case $currentBranch in
    develop-* | develop )
        #develop find sub,creatation is forbidden
        if [[ -z $subBranch ]]; then
            echo can not found subbranch.
            exit
        fi
        git checkout $subBranch
        ;;

    release-* | hotfix-* | feature-* | bugfix-* )
        #release find sub,create a personal branch by user.name if not found
        if [[ -z $subBranch ]]; then
            #create
            if [[ -z $userName ]]; then
                echo can not found subbranch and creatation is invalid with null username.
                exit
            fi

            newBranch=$userName-$currentBranch

            git fetch origin
            if [ -f ".git/refs/heads/${newBranch}" ]; then
                git checkout ${newBranch}
            else
                if [ -f ".git/refs/remotes/origin/${newBranch}" ]; then
                    git checkout -t origin/${newBranch}
                else
                    git checkout -b ${newBranch}
                    git push origin ${newBranch}
                fi
            fi

            sh $GITZ_DIR/gitf-nodes -a $newBranch $currentBranch

            exit
        fi
        ;;

    master )
        #master forbidden
        echo operation on master is forbidden.
        exit
        ;;

     * )
        echo operation on other branch is forbidden.
        exit
        ;;
esac