#!/usr/bin/with-contenv bash

PATH_PFX="/run/notifier/procs/"

#echo Shell Script Running
#echo Command line arguments - single string: $@
#echo "\$NOTIFIERS: $NOTIFIERS"

echo "100 Notifier Monitor: invoked at $(date)"
if [[ -f "$PATH_PFX/$1"]]
then
  cat "$PATH_PFX/$1"
else
  echo "500 Notifier Monitor: process not found ($1)"
fi
exit 0
