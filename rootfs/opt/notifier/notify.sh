#!/usr/bin/with-contenv bash

PATH_PFX="/opt/notifier/"
TIMEOUT=15
PIDLIST=()

#echo Shell Script Running
#echo Command line arguments - single string: $@
#echo "\$NOTIFIERS: $NOTIFIERS"

echo "#200 Notifier Manager invoked successfully."

IFS="," read -ra Apps <<< "$NOTIFIERS"
echo "#200 Notifiers configured: ${Apps[@]}"

# Start all the notifiers in parallel:
for Notifier in "${Apps[@]}"
do
  Exec_string="${PATH_PFX}/${Notifier}/${Notifier}"
  if [[ -f "${Exec_string}" ]]
  then
    echo "#200 Invoking ${Notifier}"
    "${Exec_string}" "${@}" >/dev/null 2>&1 & PIDLIST+=("$!") && PROCLIST+=(${Notifier})
  else echo "#500 Error - ${Notifier}: handler not found"
  fi
done

# Now wait for all the notifiers to finish, for up to a maximum of $TIMEOUT seconds:
pids=( ${PIDLIST[*]} )
echo "#100 monitoring ${pids[@]}"
STARTTIME=$(date +%s)
while (( $(date +%s) < STARTTIME + TIMEOUT ))
do
  sleep 1
  # you can only wait on a pid once
  remainingpids=()
  for pid in ${pids[*]}
  do
    if ! ps -p $pid >/dev/null
    then
      # the handler exited and we need to check if there was an error
      wait $pid
      exit_code=$?
      if [[ "$exit_code" == "0" ]]
      then
        echo -n "#200 Success: "
        for (( n=0; n<${#PIDLIST[@]}; n++ ))
        do
          [[ "$pid" == "${PIDLIST[n]}" ]] && echo "${PROCLIST[n]}: exited(${exit_code})"
        done
      else
        echo -n "#500 Error: "
        for (( n=0; n<${#PIDLIST[@]}; n++ ))
        do
          [[ "$pid" == "${PIDLIST[n]}" ]] && echo "${PROCLIST[n]}: exited(${exit_code})"
        done
      fi
    else
      remainingpids+=("$pid")
    fi
  done
  pids=( ${remainingpids[*]} )

  # exit the loop if there are no further PIDs remaining:
  [[ "${#pids[@]}" == "0" ]] && break
done

# We're done. All that's left is to check that there are no dangling background processes
# that weren't finished before the timeout hit:
if [[ "${#pids[@]}" != "0" ]]
then
  # we ran into a time-out!
  for pid in ${pids[*]}
  do
    echo -n "#500 Time-out Error after $TIMEOUT seconds: "
    for (( n=0; n<${#PIDLIST[@]}; n++ ))
    do
      [[ "$pid" == "${PIDLIST[n]}" ]] && echo "${PROCLIST[n]}"
    done
    kill -9 $pid
  done
fi
