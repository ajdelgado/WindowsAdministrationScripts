foreach ($pkgline in (choco list --local | select-string -NotMatch "packages installed." | select-string -notmatch 'This is try' | select-string -NotMatch 'Maximum tries' | select-string -NotMatch 'Chocolatey v'))
{
    $pkg = ($pkgline -split " ")[0]
    # Adobe Reader doesn't update, so avoiding it and also all patches that should NOT need updates
    if (($pkg -ne "") -and ($pkg -notmatch 'KB*') -and ($pkg -notmatch 'adobereader')) {
      write-host "Upgrading '$pkg'..."
      choco upgrade $pkg
    }
}