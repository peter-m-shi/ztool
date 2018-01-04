#!/bin/sh

sh $GITF_DIR/gitf-init.sh

if [[ $2 = "go" ]]; then
    sh $GITF_DIR/gitf-base.sh -a $1 "develop|release"
    git flow bugfix start $1
elif [[ $2 = "ok" ]]; then
    sh $GITF_DIR/gitf-base.sh -d $1
    git flow bugfix finish $1
else
    echo "unkonw argument:$2"
fi