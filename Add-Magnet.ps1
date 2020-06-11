Param(
    [Parameter(Mandatory=$true, Position=0)]
    [String[]]$URIs,

    [Parameter(Mandatory=$false)]
    [String]$Server="localhost",

    [Parameter(Mandatory=$false)]
    [String]$Port="9091",

    [Parameter(Mandatory=$false)]
    [String]$Username="transmission",

    [Parameter(Mandatory=$false)]
    [String]$Password
)

function Add-LogEntry {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]$Message,
        
        [Parameter(Mandatory=$false)]
        [String]$LogFile="$env:USERPROFILE\logs\magnets.log"
    )
    $LogPath=Split-Path $LogFile
    if (-not (Test-Path -Path $LogPath)) { new-Item -ItemType Directory $LogPath }
    $CurrentTime = Get-Date -UFormat "%Y/%m/%d %H:%M%:%S"
    $Text = "$CurrentTime $Message"
    Write-Host $Text
    $Text | out-file -Append $LogFile
}

foreach ($URI in $URIs) {
    if (Test-Path $URI) {
        Add-LogEntry "Received a file '$URI'"
        $torrent_content=Get-Content $URI
        $torrent_content_bytes=[System.Text.Encoding]::Unicode.GetBytes($torrent_content)
        $torrent_base64encoded=[Convert]::ToBase64String($torrent_content_bytes)
        $request = @{
            "arguments"= @{
                "metainfo"= $torrent_base64encoded;
                "paused"= $false
            };
            "method"= "torrent-add"
        }
    } else {
        Add-LogEntry "Received a Magnet URI '$URI'"
        $request = @{
            "arguments"= @{
                "filename"= $URI;
                "paused"= $false
            };
            "method"= "torrent-add"
        }
    }
    $pwd = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object Management.Automation.PSCredential ($Username, $pwd)
    Add-LogEntry "Initiating RPC session"
    Invoke-WebRequest -Uri "https://$($Server):$Port/transmission/rpc" -Credential $cred -ErrorAction SilentlyContinue
    #Add-LogEntry "Last error '$($Error[0])'"
    $ResultMatch = $Error[0] -match "X-Transmission-Session-Id: (?<sessionid>.*)$"
    if ($Matches.count -lt 1) {
        Add-LogEntry "Unable to obtain a session, check your credentials."
        exit 1
    }
    Write-Debug $ResultMatch
    $sessionid=$Matches['sessionid']
    Add-LogEntry "Obtained session id '$sessionid'"
    Add-LogEntry "Adding the torrent"
    $Result = Invoke-RestMethod -method Post -Uri "https://$($Server):$Port/transmission/rpc" -Body (convertto-json $request) -Credential $cred -Headers @{ 'X-Transmission-Session-Id' = $sessionid }
    Add-LogEntry "Arguments: $($Result.arguments)"
    Add-LogEntry "Result: $($Result.result)"
}