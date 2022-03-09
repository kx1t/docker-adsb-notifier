# docker-planefence-notifier
 Notification container to be used with kx1t/docker-planefence

 Quick things --
 1. Use the attached `docker-compose.yml` as an example
 2. Use the screenshot container in the same stack
 3. Do not use this container via a reverse web proxy as the POST parameters probably won't get correctly propagated
 4. Usage example initial notification POST:
 ```
$ curl -d "a=a&b=b&icao=a3355e" http://localhost:9999/notify.php`
100 Notifier Manager: invoked at Tue Mar  8 12:17:26 EST 2022
100 Notifier Manager: configured handlers: twitter discord mqtt ifttt
202 twitter: invoked - callback handler: twitter-300
500 discord: error: handler not found
202 mqtt: invoked - callback handler: mqtt-300
202 ifttt: invoked - callback handler: ifttt-300
```
 5. Usage example to poll for status or results:
 ```
$ curl -d "status=twitter-300" http://prod:9999/notify.php`
100 Notifier Monitor: invoked at Tue Mar  8 12:33:21 EST 2022
100 20220308-123250-0500 #twitter: cmdline args = a=a b=b icao=a3355e notifyproc=300
102 20220308-123250-0500 #twitter: twitter notifier
102 invoking /opt/notifier/getscreenshot.sh a3355e 300
200 20220308-123316-0500 #twitter: file=/run/notifier/screenshot//a3355e-300.png
200 20220308-123316-0500 #twitter: GetScreenshot is finished, now we can do other things...
```

 6. Do not use spaces in notification handlers and make sure they are unique

 # HTTP Push parameters

 The proxy will accept any key=value pair that is passed to `notify.php` using HTTP POST, but to standardize things a bit, we are using the following parameters
 | POST parameter | POST value or explanation      | POST value default if omitted                 |
 |----------------|--------------------------------|-----------------------------------------------|
 | icao           | Hex ID for taking a screenshot | No screenshot is taken if omitted             |
 | message_text   | String with notification text  | No notification is sent if this text is empty |
 | notify_to      | comma separated list of notification handlers to be used | If empty, notification will go to all configured handlers |
 | screenshot     | "on" or "off"                  | "on" (should fail softly if no screenshot container available) |

 7. Container variables

 ### SCREENSHOT
 | Variable | Values or explanation | Default value if omitted |
 |----------|-----------------------|--------------------------|
 | SCREENSHOT | "on" or "off" | "on" -- even if screenshot retrieval fails, notifications should continue without screenshot |
 | SCREENSHOT_URL | URL to access the `screenshot` container | http://screenshot:5042 |
 | SCREENSHOT_TIMEOUT | time (secs) to wait for screenshot container to return a screenshot  | 45 (seconds) |
 | SCREENSHOT_RETENTION | time to retain a screenshot for use by notification handlers  | 600 (seconds) |
