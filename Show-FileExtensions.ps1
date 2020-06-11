#Requires -RunAsAdministrator
# Set Explorer to show file extensions by default and for current user
$regpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt"
Set-ItemProperty $regpath DefaultValue 1
$regpath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty $regpath HideFileExt 1
