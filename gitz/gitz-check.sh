#!/bin/sh

if [ -d .git ]; then
	exit 0
fi

exit 1
