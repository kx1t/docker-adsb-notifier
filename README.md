# docker-planefence-notifier
 Notification container to be used with kx1t/docker-planefence

 Quick things --
 1. Use the attached `docker-compose.yml` as an example
 2. Use the screenshot container in the same stack
 3. Do not use this container via a reverse web proxy as the POST parameters probably won't get correctly propagated
 4. Usage example initial notification POST: `curl -d "a=a&b=b&icao=a3355e" http://localhost:9999/notify.php`
 5. Usage example to poll for status or results: `curl -d "status=twitter-320" http://prod:9999/notify.php`
