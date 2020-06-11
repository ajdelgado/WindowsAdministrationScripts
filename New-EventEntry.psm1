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
