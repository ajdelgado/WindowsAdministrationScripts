$destination="Z:\software\Android apks"
#$devices=$(adb devices | Where-Object { $_ -match '\tdevice$' }) -replace '\tdevice',''
function Get-DeviceList {
    $result = @()
    $devices=$(adb devices -l | Where-Object { $_ -notmatch 'List of devices' -and $_ -notmatch '^$'})
    foreach ($device in $devices) {
        $result_device=@{}
        foreach ($field in $($device -replace "        ","" -split " ")) {
            $lfield=$field -split ":"
            if ($lfield[1] -ne $null) {
                $result_device[$lfield[0]] = $lfield[1]
            } else {
                if ($lfield[0] -ne '') {
                    $result_device['serial']=$lfield[0]
                }
            }
        }
        $result_device['name'] = $(adb -t $result_device['transport_id'] shell dumpsys bluetooth_manager | select-string "name: ") -replace '  name: ',''
        $result += $result_device
    }
    return $result
}
$devices=Get-DeviceList
foreach ($device in $devices) {
    write-host "Getting apps from device '$($device['name']) ($($device['serial']))..."
    if (-not (test-path "$destination\$($device['name'])")) {
        new-item -path "$destination\$($device['name'])" -itemtype directory
    }
    foreach ($app_entry in $(adb -t $device['transport_id'] shell pm list packages -3 -f)) {
        $full_apk_name=$app_entry -replace '^package:',''
        $full_apk_name="$($full_apk_name -replace 'base.apk=.*','base.apk')"
        $apk_name="$($app_entry -replace '.*=','').apk"
        write-host "Saving app '$full_apk_name' into '$destination\$($device['name'])\$apk_name'"
        adb -t $device['transport_id'] pull $full_apk_name "$destination\$($device['name'])\$apk_name"
    }
}