#!/bin/sh

sh $GITF_DIR/gitf-init.sh

if [[ $2 = "go" ]]; then
    sh $GITF_DIR/gitf-base.sh -a feature.$1 "develop"
    git flow feature start $1
elif [[ $2 = "ok" ]]; then
    sh $GITF_DIR/gitf-base.sh -d feature.$1
    git flow feature finish $1
else
    echo "unkonw argument:$2"
fi