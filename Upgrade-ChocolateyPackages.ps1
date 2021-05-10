#Requires -RunAsAdministrator
Remove-Item -Recurse -Path "$env:windir\temp\chocolatey"
foreach ($pkgline in (choco list --local-only | select-string "^[a-zA-Z0-9\-]* [0-9\.]*$"))
{
    $pkg = ($pkgline -split " ")[0]
    # Adobe Reader doesn't update, so avoiding it and also all patches that should NOT need updates
    if (($pkg -ne "") -and ($pkg -notmatch 'KB*') -and ($pkg -notmatch 'adobereader')) {
      write-host "Upgrading '$pkg'..."
      choco upgrade $pkg
    }
}