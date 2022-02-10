#!/usr/bin/with-contenv bash

# -----------------------------------------------------------------------------------
# Copyright 2020 - 2022 Ramon F. Kolb (kx1t) - licensed under the terms and conditions
# of GPLv3. The terms and conditions of this license are included with the Github
# distribution of this package, and are also available here:
# https://github.com/kx1t/docker-planefence-notifier
# -----------------------------------------------------------------------------------

PATH_PFX="/opt/notifier/"
TIMEOUT=15
PIDLIST=()

#echo Shell Script Running
#echo Command line arguments - single string: $@
#echo "\$NOTIFIERS: $NOTIFIERS"

echo "100 Notifier Manager: invoked at $(date)"

IFS="," read -ra Apps <<< "$NOTIFIERS"
echo "100 Notifier Manager: configured handlers: ${Apps[@]}"

# Start all the notifiers in parallel:
for Notifier in "${Apps[@]}"
do
  Exec_string="${PATH_PFX}/${Notifier}/${Notifier}"
  if [[ -f "${Exec_string}" ]]
  then
    monitorproc="$$"
    nohup "${Exec_string}" "${@}" "notifyproc=$monitorproc" > "/run/notifier/procs/${Notifier}-$monitorproc" 2>&1 &
    echo "202 ${Notifier}: invoked - callback handler: ${Notifier}-$monitorproc"
  else echo "500 ${Notifier}: error: handler not found"
  fi
done
exit 0
