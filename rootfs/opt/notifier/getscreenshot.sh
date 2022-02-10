#!/usr/bin/with-contenv bash

# -----------------------------------------------------------------------------------
# Copyright 2020 - 2022 Ramon F. Kolb (kx1t) - licensed under the terms and conditions
# of GPLv3. The terms and conditions of this license are included with the Github
# distribution of this package, and are also available here:
# https://github.com/kx1t/docker-planefence-notifier
# -----------------------------------------------------------------------------------

# Usage: getscreenshot.sh <icao> [<procid>]
# Return on success: exit 0 and link to PNG written to stdout
# Return on failure: exit 99 and nothing written to stdout
# If it's already processing a screenshot for this process: exit 1 and wait time for retry is written to  stdout
# Uses and invokes @Tedder's screenshot container
#
# The script is "smart" in the sense that it detects if a recent screenshot was
# retrieved for the same process, it will reuse that one.

[[ "$SCREENSHOT_URL" == "" ]] && SCREENSHOT_URL="http://screenshot:5042"
[[ "$SCREENSHOT_TIMEOUT" == "" ]] && SCREENSHOT_TIMEOUT=45  # in seconds
[[ "$SCREENSHOT_RETENTION" == "" ]] && SCREENSHOT_RETENTION=600  # in seconds
[[ "$SCREENSHOT_DIR" == "" ]] && SCREENSHOT_DIR="/run/notifier/screenshot/"
ICAO="$1"
PROCID="$2"

mkdir -p "${SCREENSHOT_DIR}"
# Figure out the filename. If there's a ProcID - use that to see if there's an existing file for this ICAO.
# If there's no ProcID --> use "ICAO.png" as file name.
# If there is a ProcID --> use "ICAO-ProcID.png" as file name
if [[ "${PROCID}" != "" ]]
then
  SCREENSHOT_FILE="${SCREENSHOT_DIR}/${ICAO}.png"
else
  SCREENSHOT_FILE="${SCREENSHOT_DIR}/${ICAO}-${PROCID}.png"
fi

# Check if some other process is already making this screenshot. If so, tell the user to try again later:
if [[ -f "${SCREENSHOT_FILE}.lock" ]]
then
  echo "${SCREENSHOT_TIMEOUT}"
  exit 1
fi

# wait some random time (between 0 and 2 seconds), check again, and if the lock file still doesn't exit, then create it:
sleep $(bc -l <<< "$RANDOM / 32767 * 2 ")
if [[ -f "${SCREENSHOT_FILE}.lock" ]]
then
  echo "${SCREENSHOT_TIMEOUT}"
  exit 1
fi

# immediately lock the effort so other processes don't duplicate the creation:
touch "${SCREENSHOT_FILE}.lock"

# do some clean-up:
find "${SCREENSHOT_DIR}" -type f -mmin +"$(( SCREENSHOT_RETENTION / 60 ))" -delete >/dev/null 2>&1

# Now get the screenshot if it doesn't already exist:
if [[ -f "${SCREENSHOT_FILE}" ]]
then
  # we already have a valid screenshot - no need to generate one.
  echo "${SCREENSHOT_FILE}"
  exitcode=0
else
  if curl -L -s --max-time $SCREENSHOT_TIMEOUT --fail "${SCREENSHOT_URL}/snap/${ICAO}" -o "${SCREENSHOT_FILE}"
  then
    # success getting a screenshot
    echo "${SCREENSHOT_FILE}"
    exitcode=0
  else
    exitcode=99
  fi
fi

# remove lock
rm -rf "${SCREENSHOT_FILE}.lock"

exit $exitcode
