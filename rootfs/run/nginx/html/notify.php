<?php
  // concatenate the input strings into a single argument string

  $argstring = "";
  foreach ($_POST as $key => $value) {
    $key = escapeshellarg($key);
    $value = escapeshellarg($value);
    $argstring .= "--{$key}={$value} ";
  }

  //  echo "Argument = " . $argstring;
  system("/opt/notifier/notify.sh {$argstring}", $return_value);
  ($return_value == 0) or die("#php error returned an error: $return_value");

?>
