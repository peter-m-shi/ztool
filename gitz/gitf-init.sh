#!/bin/sh

sh $GITZ_DIR/gitz-check.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi

git config --list | grep gitflow >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    echo "init config."
    git config gitflow.branch.master master
    git config gitflow.branch.develop develop
    git config gitflow.prefix.feature feature-
    git config gitflow.prefix.release release-
    git config gitflow.prefix.hotfix hotfix-
    git config gitflow.prefix.bugfix bugfix-
    git config gitflow.prefix.support support-
    git config gitflow.prefix.versiontag V
fi