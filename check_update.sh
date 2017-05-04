#!/usr/bin/env zsh

TOOLS_FOLDER="$HOME/ztool"

zmodload zsh/datetime

function _current_epoch() {
  echo $(( $EPOCHSECONDS / 60 / 60 / 24 ))
}

function _update_time() {
  echo "LAST_EPOCH=$(_current_epoch)" >! $TOOLS_FOLDER/.tools-timestamp
}

function _upgrade_tools() {
  env ZSH=$ZSH /bin/sh $TOOLS_FOLDER/update.sh
  # update the tools file
  _update_time
}

epoch_target=$PGTOOLS_AUTO_DAYS
if [[ -z "$epoch_target" ]]; then
  # Default to old behavior
  epoch_target=1
fi

# Cancel upgrade if the current user doesn't have write permissions for the

#检查更新
if [ -f $TOOLS_FOLDER/.tools-timestamp ]
then
  . $TOOLS_FOLDER/.tools-timestamp

  if [[ -z "$LAST_EPOCH" ]]; then
    _update_time && return 0;
  fi

  epoch_diff=$(($(_current_epoch) - $LAST_EPOCH))

  if [ $epoch_diff -gt $epoch_target ]
  then
    if [ "$PGTOOLS_AUTO_CHECK" = "false" ]
    then

    else
      env ZSH=$ZSH /bin/sh $TOOLS_FOLDER/check_changes.sh &
      _update_time
    fi
  fi
else
  # create the tools file
  _update_time
fi

#提示更新
if [ -f $TOOLS_FOLDER/.tools-changes ]
then
    log=$(cat $TOOLS_FOLDER/.tools-changes)

    if [[ -n "$log" ]]; then
      echo "[ztool] has one or more updates:"
      echo "----------------------------"
      sh "$TOOLS_FOLDER/utility/echoColor.sh" "-yellow" "$log"
      echo "----------------------------"
      echo "Would you like to update for ztool?"
      str="\033[32mY\033[0m"
      echo "Type $str to update: \c"
      read line
      if [ "$line" = Y ] || [ "$line" = y ]; then
        _upgrade_tools
      fi
    fi

    rm -rf $TOOLS_FOLDER/.tools-changes

    exec zsh
fi


