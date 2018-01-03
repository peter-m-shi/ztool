#!/bin/sh

sh $GITF_DIR/gitf-init.sh

if [[ $2 = "go" ]]; then
    git flow release start $1
elif [[ $2 = "ok" ]]; then
    git flow release finish $1
else
    echo "unkonw argument:$2"
fi