#!/bin/bash

echo ----当前mobileprovision列表----:
ls "$HOME"/'Library/MobileDevice/Provisioning Profiles'/
echo

rm -Rf "$HOME"/'Library/MobileDevice/Provisioning Profiles'/*

echo
echo ----全部清空----