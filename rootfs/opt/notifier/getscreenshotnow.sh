#!/usr/bin/with-contenv bash
#
# Usage: getscreenshotnow.sh icao notifyproc

# Use the following response conventions:
# "RESPCODE yyyymmdd-hhmmss-zzzz #servicename: info-text"
# Where:
# RESPCODE= 100 (info only), 102 (continue to process), 200 (done processing), 500 (fatal error)
# Date string can be obtained with $(date +"%Y%m%d-%H%M%S%z")
# Service name should be set as a constant
#
# Request parameters are passed to this service via the command line ($[@]) in the format "key=value"
#
# The notifier plugin writer is responsible to ensure that all notification processes finish properly.
# Notification execution should NOT be swapped to the background, but is allowed to block this process until done.
# Any output that is written to stdout from this process will be captured and made available to the requestor by
# POSTing "status=callback-handler" to "notify.php". The callback-handler was provided in the reponse
# to the original notification request.

# Define any notification-internal constants below.
# Do not change the $SERVICE variable definition.
#
# Note that ${param[notifyproc]} will contain a unique process identifier (in format "handler-xxx" where xxx is the Linux process ID)
# to point at this specific instance of the notification. It can be used to get unique screenshots, create referable files, etc.

SERVICE="${0##*/}"
MAXWAITTIME=60

echo "100 $(date +"%Y%m%d-%H%M%S%z") #${SERVICE}: ${@}"
icao="$1"
procid="$2"

STARTTIME="$(date +%s)"
while (( $(date +%s) < (STARTTIME + MAXWAITTIME) ))
do
  IFS=" " read -ra resultarray <<< "$(/opt/notifier/getscreenshot-core.sh "$icao" "${procid}")"
  returnvalue="$?"
  result=${resultarray[1]}
  case "$returnvalue" in
    "0")
      echo "200 $(date +"%Y%m%d-%H%M%S%z") #${SERVICE}: file=${result}"
      break
    ;;

    "1")
      echo "102 $(date +"%Y%m%d-%H%M%S%z") #${SERVICE}: waiting 15 seconds"
      # Sleep for the time that the getscreenshot service recommends before trying again to get the results.
      # This is based on the longest time it could take for the service to return a screenshot: default=45 secs.
      # Based on your preferences, you may decide to check more often, for example in 10 seconds intervals.
      sleep "15s"
      continue
    ;;

    "2")
      echo "102 $(date +"%Y%m%d-%H%M%S%z") #${SERVICE}: waiting for another request to finish before retrying"
      sleep "$result"
      continue
    ;;

    *)
      echo "500 $(date +"%Y%m%d-%H%M%S%z") #${SERVICE}: GetScreenshot unsuccessful, returned $returnvalue"
      break
    ;;
  esac
done
echo "200 $(date +"%Y%m%d-%H%M%S%z") #${SERVICE}: GetScreenshot is finished, now we can do other things..."






exit 0
