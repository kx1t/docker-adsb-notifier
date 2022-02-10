<?php
  // concatenate the input strings into a single argument string

if (isset($_POST['status']))
{
  $notif_id = escapeshellarg($_POST['status']);

  system("/opt/notifier/monitor.sh {$notif_id}", $return_value);
  ($return_value == 0) or die("500 php error({$return_value})");
} else
{
  $argstring = "";
  foreach ($_POST as $key => $value)
  {
    $key = escapeshellarg($key);
    $value = escapeshellarg($value);
    $argstring .= "{$key}={$value} ";
  }

  system("/opt/notifier/notify.sh {$argstring}", $return_value);
  ($return_value == 0) or die("500 php error({$return_value})");
}
?>
