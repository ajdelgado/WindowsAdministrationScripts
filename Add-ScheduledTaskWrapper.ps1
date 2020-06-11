#Requires -RunAsAdministrator
Param(
    [Parameter(Mandatory=$true, Position=0)]
    [String]$ScriptFile,

    [Parameter(Mandatory=$true, Position=1)]
    [String]$TaskName,

    [Parameter(Mandatory=$false)]
    [String]$UserName='SYSTEM',

    [Parameter(Mandatory=$false)]
    [Boolean]$AtLogon=$false,

    [Parameter(Mandatory=$false)]
    [Int]$Minutes
)
$Action = New-ScheduledTaskAction -Execute "$env:systemroot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-File '$ScriptFile' -ExecutionPolicy Unrestricted -WindowStyle Hidden -NonInteractive -NoLogo"
if ($AtLogon) {
    write-host "Executing task at logon."
    $Trigger = New-ScheduledTaskTrigger -AtLogon
} elseif ($Minutes) {
    Write-Host "Executing task every $Minutes minutes starting now."
    $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $Minutes)
} else {
    Write-Error "You must indicate a repetition interval in Minutes or AtLogon"
    exit 0
}
$Principal = New-ScheduledTaskPrincipal $UserName
$Settings = New-ScheduledTaskSettingsSet
$Result = Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Principal $Principal -Settings $Settings -Action $Action
write-host $Result