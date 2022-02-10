#!/usr/bin/with-contenv bash

# -----------------------------------------------------------------------------------
# Copyright 2020 - 2022 Ramon F. Kolb (kx1t) - licensed under the terms and conditions
# of GPLv3. The terms and conditions of this license are included with the Github
# distribution of this package, and are also available here:
# https://github.com/kx1t/docker-planefence-notifier
# -----------------------------------------------------------------------------------

PATH_PFX="/run/notifier/procs/"

#echo Shell Script Running
#echo Command line arguments - single string: $@
#echo "\$NOTIFIERS: $NOTIFIERS"

echo "100 Notifier Monitor: invoked at $(date)"
if [[ -f "$PATH_PFX/$1" ]]
then
  cat "$PATH_PFX/$1"
else
  echo "500 Notifier Monitor: process not found ($1)"
fi
exit 0
