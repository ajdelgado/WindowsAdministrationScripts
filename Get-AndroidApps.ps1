$destination="Z:\software\Android apks\Afuf"
foreach ($app in $(adb shell pm list packages -3 -f)) {
    $fapk=$app -replace '^package:',''
    $fapk="$($fapk -replace 'base.apk=.*','base.apk')"
    $apk="$($app -replace '.*=','').apk"
    write-host $fapk
    write-host $apk
    adb pull $fapk $destination\$apk
}