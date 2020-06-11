#Requires -RunAsAdministrator
# Set a list of hosts to be routed via Wi-Fi instead of wired network
#
# To install:
# Create a Task triggered by a System event with source Netwtw06 and ID
# 7021 ("Connection telemetry fields and analysis usage") to run this script
# as System with elevated priviledges
Param(
  [Parameter(Mandatory=$true)]
  [String[]]$Hosts
)
function New-EventEntry {
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    [String]$Message,

    [Parameter(Mandatory=$false)]
    [Int]$EventId=0,

    [Parameter(Mandatory=$false)]
    [String]$EntryType='Information',

    [Parameter(Mandatory=$false)]
    [String]$Logfile="$env:systemroot\Logs\Events.log", # This would be replace in code for the script filename

    [Parameter(Mandatory=$false)]
    [String]$MaxLogSize=100000000
  )
  $PathParts=$MyInvocation.ScriptName -split "\\"
  $ScriptFileName=$PathParts[$PathParts.Length-1]
  $AppName=$ScriptFilename -replace ".ps1$",""
  $Source=$AppName

  if ($Logfile -eq "$env:systemroot\Logs\Events.log") {
    $Logfile="$env:systemroot\Logs\$AppName.log"
  }
  $Logfolder=Split-Path $Logfile -Parent
  if (-not (Test-Path $Logfolder)) {
    new-item $Logfolder -ItemType Directory
  }

  # Write to disk the log entry
  $current_date = get-date -UFormat '%Y-%m-%d %H:%M:%S'
  "$current_date $Message" | out-file -append $Logfile
  if ((Get-Item $Logfile).Length -gt $MaxLogSize) {
    if (test-path "$Logfile.bak") {
      move-item "$Logfile.bak" "$Logfile.bak.1" -force
    }
    move-item $Logfile "$Logfile.bak" -force
  }

  New-EventLog -Source $Source -LogName Application -ErrorAction SilentlyContinue
  write-host $Message
  Write-EventLog -LogName Application -Source $Source -EventID $EventId -EntryType $EntryType -Message $Message
}

$wifi_index = -1
Foreach ($connection in (Get-NetConnectionProfile)) {
  if ($connection.Name -eq 'LT_visitors') {
    New-EventEntry "We are connected to LT_visitors, adding routes..."
    $wifi_index = $connection.InterfaceIndex
    $wifi_alias = $connection.InterfaceAlias
    $gateway =  (get-netroute -InterfaceIndex $wifi_index -DestinationPrefix 0.0.0.0/0).NextHop
  }
}
if ($wifi_index -eq -1) {
  New-EventEntry "We are not connected to LT_visitors, removing routes..."
}
foreach ($ahost in $Hosts) {
  New-EventEntry "Setting route for $ahost..."
  $result=Resolve-DnsName  $ahost -type A
  New-EventEntry "Obtained IP $($result.IPAddress)"
  $host_ip=$result.IPAddress
  if ($wifi_index -ne -1) {
      if (-not (Get-NetRoute -DestinationPrefix "$host_ip/32" -erroraction silent)) {
        New-NetRoute -InterfaceAlias $wifi_alias -DestinationPrefix "$host_ip/32" -NextHop $gateway -erroraction Stop
        New-EventEntry "Added route for $ahost via guest network"
      } else {
        set-NetRoute -InterfaceAlias $wifi_alias -DestinationPrefix "$host_ip/32" -NextHop $gateway -erroraction Stop
        New-EventEntry "Updated route for $ahost via guest network"
      }

  } else {
    if (-not (Get-NetRoute -DestinationPrefix "$host_ip/32" -erroraction silent)) {
      New-EventEntry "There was no preexisting route for $ahost."
    } else {
      remove-netroute -DestinationPrefix "$host_ip/32" -Confirm:$False -erroraction stop
      New-EventEntry "Removed route for $ahost"
    }
  }
}