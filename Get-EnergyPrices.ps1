$price_limit=6
$url="https://sahko.tk/api.php"
$payload="mode=get_prices"
$nicehash_url="https://api2.nicehash.com"
$organization="27b15942-2d23-4b65-a953-277a8e54f80f"
$API_KEY="63001cdd-542e-49cb-abbd-be517db9e4ba"
$API_SECRET="4f82d327-6513-4117-bf27-c4880527bb893efcfe0e-71bf-4f07-a39e-8c729384aad3"
$rig_id="0-DdkXOW9T0UGKoa4z2UGWvA"
$result = Invoke-WebRequest -Uri $url -method "POST" -body $payload | ConvertFrom-Json
write-host "Prices: ${result}"
$current_price = $result.now
Write-Host "Current price: $current_price"
$timestamp=([System.DateTimeOffset]::UtcNow).ToUnixTimeMilliseconds()
$result=Invoke-WebRequest -uri "https://api2.nicehash.com/api/v2/time" | convertfrom-json
$server_time=$result.serverTime
$diff_time=$server_time-$timestamp
if ($diff_time -gt 300000) {
    write-host "Time offset with server is too high (${diff_time} ms > 300000 ms)"
    exit 1
} else {
    write-host "Server time: ${server_time} (Difference: ${diff_time} ms)"
}
$random=$(new-guid)
$request_id=$(new-guid)
$zero_byte=[char]0
$zero_array=@(0)
$zero_byte=[system.text.encoding]::utf8.getstring($zero_array)
$url_path="/main/api/v2/mining/rigs/status2"
if ($current_price -gt $price_limit) {
    write-host "Price is higher than limit of ($price_limit), stopping mining..."
    $body="{`"rigId`":`"${rig_id}`",`"action`":`"STOP`"}"
    $parameters="rigId=${rid_id}&action=STOP"
    $parameters=""
    $message="${API_KEY}${zero_byte}${timestamp}${zero_byte}${random}${zero_byte}${zero_byte}${organization}${zero_byte}${zero_byte}POST${zero_byte}${url_path}${zero_byte}${parameters}${zero_byte}${body}"
    write-host $message
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($API_SECRET)
    $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
    #$signature = [Convert]::ToBase64String($signature)
    $signature = [System.BitConverter]::ToString($signature).Replace('-','').ToLower()
    $headers=@{"X-Time"=$timestamp;
           "X-Nonce"=$random;
           "X-Organization-Id"=$organization;
           "X-Request-Id"=$request_id;
           "X-Auth"="${API_KEY}:${signature}"}
    write-host "Headers: $($headers|convertto-json)"
    write-host $(invoke-WebRequest -Uri "${nicehash_url}${url_path}" -method "POST" -headers $headers -body $body)
    
} else {
    write-host "Price is lower than limit of ($price_limit), starting mining..."
    $body='{"group":"","action":"START"}'
    $parameters="group=&action=START"
    $message="${API_KEY}${zero_byte}${timestamp}${zero_byte}${random}${zero_byte}${zero_byte}${organization}${zero_byte}${zero_byte}POST${zero_byte}${url_path}${zero_byte}${parameters}${zero_byte}${body}"
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($API_SECRET)
    $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
    $signature = [Convert]::ToBase64String($signature)    
    $headers=@{"X-Time"=$timestamp;
               "X-Nonce"=$random;
               "X-Organization-Id"=$organization;
               "X-Request-Id"=$request_id;
               "X-Auth"="${API_KEY}:${signature}"}
    write-host $(invoke-WebRequest -Uri "${nicehash_url}${url_path}" -method "POST" -headers $headers -body $body)
}