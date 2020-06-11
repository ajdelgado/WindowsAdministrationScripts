#Requires -RunAsAdministrator
$scriptfile = "C:\Users\adelgado\repos\scripts\Route-outsidehosts.ps1"
$Action = New-ScheduledTaskAction -Execute "$env:systemroot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-File '$scriptfile' -ExecutionPolicy Unrestricted -WindowStyle Hidden -NonInteractive NoLogo"
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Principal = New-ScheduledTaskPrincipal "Contoso\Administrator"
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Principal $Principal -Trigger $Trigger -Settings $Settings
$Result = Register-ScheduledTask T1 -InputObject $Task
