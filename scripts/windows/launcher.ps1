# Opens the game's launcher (settings, mods, PLAY): launcher\AscensionLauncher.exe, or its
# source in ..\work\launcher when the .exe is not there (or with -Source).
#   .\scripts\windows\launcher.ps1          the window
#   .\scripts\windows\launcher.ps1 -Play    start the game with the saved settings, no window
param([switch]$Play, [switch]$Source)
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Exe = Join-Path $Root "launcher\AscensionLauncher.exe"
$Py = Join-Path (Split-Path -Parent $Root) "work\launcher\ascension_launcher.py"
if ((Test-Path $Exe) -and -not $Source) {
    if ($Play) { Start-Process $Exe -ArgumentList "--play" -Wait } else { Start-Process $Exe }
} elseif ($Play) { python $Py --play } else { Start-Process pythonw -ArgumentList "`"$Py`"" }
