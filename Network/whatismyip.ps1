$ip = (Invoke-WebRequest -uri "https://api.ipify.org").content
$ip