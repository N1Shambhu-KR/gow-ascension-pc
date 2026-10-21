# Replay captured SPU jobs (ps3kit runtime/spu/spu_jobcap.c) outside the
# game and check them: the bytes each job PUT, and with -Save / -Base the
# whole local store and registers at its return.
#
#   .\scripts\windows\replay.ps1 -Save -Env @{ GOWA_NATIVE_OFF = "all" }   # lifted baseline into work\edge_cases\<set>_end
#   .\scripts\windows\replay.ps1 -Base                                      # this build against it
#   .\scripts\windows\replay.ps1 -Sets level6 -Runs 20                      # timing only
#
# Sets are folders of work\edge_cases (default level6 and boot218). Logs in
# build\logs\replay-<set>[-<Name>].err; prints each set's summary lines and the
# first differing jobs.
param(
    [string[]]$Sets = @("level6", "boot218"),
    [int]$Runs = 1,
    [switch]$Save,
    [switch]$Base,
    [hashtable]$Env = @{},
    [string]$Name = ""
)

. (Join-Path $PSScriptRoot "env.ps1")
$Exe  = Join-Path $Root "build\win\AscensionRecomp.exe"
$Elf  = Join-Path $Cfg.WORK_DIR "disc\PS3_GAME\USRDIR\EBOOT.ELF"
$Logs = Join-Path $Root "build\logs"
$failed = 0
foreach ($set in $Sets) {
    $dir = Join-Path $Cfg.WORK_DIR "edge_cases\$set"
    $end = Join-Path $Cfg.WORK_DIR "edge_cases\${set}_end"
    $vars = @{ SPU_JOB_REPLAY = "$dir,5,$Runs" }
    if ($Save) { New-Item -ItemType Directory -Force $end | Out-Null; $vars.SPU_JOB_REPLAY_LS = "save,$end" }
    elseif ($Base) { $vars.SPU_JOB_REPLAY_LS = "base,$end" }
    foreach ($k in $Env.Keys) { $vars[$k] = $Env[$k] }
    $old = @{}
    foreach ($k in $vars.Keys) { $old[$k] = [Environment]::GetEnvironmentVariable($k); [Environment]::SetEnvironmentVariable($k, [string]$vars[$k]) }
    $log = Join-Path $Logs ("replay-$set" + $(if ($Name) { "-$Name" } else { "" }) + ".err")
    & $Exe $Elf 2> $log > $null
    if ($LASTEXITCODE -ne 0) { $failed++ }
    foreach ($k in $old.Keys) { [Environment]::SetEnvironmentVariable($k, $old[$k]) }
    Write-Host "== $set ($log)"
    Select-String -Path $log -Pattern '^\[replay\] (\d+ jobs|whole LS)' | ForEach-Object { Write-Host $_.Line }
    Select-String -Path $log -Pattern 'HALTED|did not return|LS bytes in' | Select-Object -First 5 | ForEach-Object { Write-Host $_.Line }
}
exit $failed
