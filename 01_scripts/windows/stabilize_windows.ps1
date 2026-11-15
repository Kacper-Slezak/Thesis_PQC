#Requires -RunAsAdministrator
<#
  Prepares Windows for low-noise benchmarks in WSL2, and restores it afterwards.

  Usage (PowerShell as Administrator):
    .\stabilize_windows.ps1              # before measurements
    .\stabilize_windows.ps1 -KeepBoost   # same, but leave CPU turbo/boost on
    .\stabilize_windows.ps1 -Restore     # after measurements

  What it does:
    * creates a separate power scheme "Thesis benchmark" (your normal scheme is not modified):
      min/max processor state 100%, CPU boost disabled (stable clock), no core parking, no sleep on AC
    * switches the Windows 11 power-mode slider to "Best performance" (if supported)
    * stops the Windows Search indexer and SysMain for the session (restarted with -Restore)
    * checks AC power and current CPU load
  Nothing is changed permanently: -Restore reactivates your previous scheme and deletes the benchmark one.
#>
param([switch]$Restore, [switch]$KeepBoost)

$StateFile = Join-Path $env:USERPROFILE 'thesis_benchmark_state.txt'
$HighPerf  = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
$Balanced  = '381b4222-f694-41f0-9685-ff5bb260df2e'
$BestPerfOverlay = 'ded574b5-45a0-4f42-8737-46345c09c238'
$Services  = @('WSearch', 'SysMain')

function Get-Guid([string]$text) {
  if ($text -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') { return $Matches[1] }
  return $null
}

# ------------------------------------------------------------------ restore
if ($Restore) {
  if (-not (Test-Path $StateFile)) { Write-Warning "No state file ($StateFile). Nothing to restore."; exit 0 }
  $state = @{}
  Get-Content $StateFile | ForEach-Object { $k, $v = $_ -split '=', 2; $state[$k] = $v }

  if ($state['PreviousScheme']) {
    powercfg /setactive $state['PreviousScheme'] | Out-Null
    Write-Host "Power scheme restored: $($state['PreviousScheme'])"
  }
  if ($state['BenchScheme']) {
    powercfg /delete $state['BenchScheme'] | Out-Null
    Write-Host "Benchmark power scheme deleted."
  }
  try { powercfg /overlaysetactive 00000000-0000-0000-0000-000000000000 2>$null | Out-Null; Write-Host "Power mode slider set back to Balanced." } catch {}

  foreach ($s in ($state['StoppedServices'] -split ',' | Where-Object { $_ })) {
    try { Start-Service $s -ErrorAction Stop; Write-Host "Service restarted: $s" } catch { Write-Warning "Could not start $s" }
  }
  Remove-Item $StateFile -Force
  Write-Host "Done. Windows is back to normal."
  exit 0
}

# ------------------------------------------------------------------ stabilize
if (Test-Path $StateFile) {
  Write-Warning "Benchmark mode seems to be active already ($StateFile exists). Run with -Restore first."
  exit 1
}

# 1) AC power
$battery = Get-CimInstance -Namespace root/WMI -ClassName BatteryStatus -ErrorAction SilentlyContinue
if ($battery -and ($battery | Where-Object { -not $_.PowerOnline })) {
  Write-Warning "Laptop is running on BATTERY. Plug in the charger before measuring."
}

# 2) Dedicated power scheme
$previous = Get-Guid (powercfg /getactivescheme)
$dup = powercfg /duplicatescheme $HighPerf 2>$null
$bench = Get-Guid "$dup"
if (-not $bench) { $bench = Get-Guid (powercfg /duplicatescheme $Balanced) }
if (-not $bench) { Write-Error "Could not create a power scheme."; exit 1 }
powercfg /changename $bench "Thesis benchmark" "Stable clocks for mTLS measurements" | Out-Null

# Unhide the processor settings we need (they are hidden on many laptops)
foreach ($setting in 'PERFBOOSTMODE', 'CPMINCORES', 'PROCTHROTTLEMIN', 'PROCTHROTTLEMAX') {
  powercfg -attributes SUB_PROCESSOR $setting -ATTRIB_HIDE 2>$null | Out-Null
}

powercfg /setacvalueindex $bench SUB_PROCESSOR PROCTHROTTLEMIN 100 | Out-Null   # min processor state 100%
powercfg /setacvalueindex $bench SUB_PROCESSOR PROCTHROTTLEMAX 100 | Out-Null   # max processor state 100%
powercfg /setacvalueindex $bench SUB_PROCESSOR CPMINCORES 100      | Out-Null   # no core parking
if (-not $KeepBoost) {
  powercfg /setacvalueindex $bench SUB_PROCESSOR PERFBOOSTMODE 0   | Out-Null   # boost OFF -> constant clock
}
powercfg /setacvalueindex $bench SUB_SLEEP STANDBYIDLE 0           | Out-Null   # never sleep on AC
powercfg /setacvalueindex $bench SUB_SLEEP HIBERNATEIDLE 0         | Out-Null
powercfg /setactive $bench | Out-Null
Write-Host "Power scheme 'Thesis benchmark' active (boost: $(if ($KeepBoost) {'on'} else {'OFF'}))."

try { powercfg /overlaysetactive $BestPerfOverlay 2>$null | Out-Null; Write-Host "Power mode slider: Best performance." } catch {}

# 3) Background services
$stopped = @()
foreach ($s in $Services) {
  $svc = Get-Service $s -ErrorAction SilentlyContinue
  if ($svc -and $svc.Status -eq 'Running') {
    try { Stop-Service $s -Force -ErrorAction Stop; $stopped += $s; Write-Host "Service stopped for the session: $s" }
    catch { Write-Warning "Could not stop $s" }
  }
}

@(
  "PreviousScheme=$previous",
  "BenchScheme=$bench",
  "StoppedServices=$($stopped -join ',')"
) | Set-Content $StateFile

# 4) Current CPU load (language-independent counter)
$samples = 1..5 | ForEach-Object {
  (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'").PercentProcessorTime
  Start-Sleep -Seconds 1
}
$avg = [math]::Round(($samples | Measure-Object -Average).Average, 1)
Write-Host "Windows CPU load (5 s average): $avg %"
if ($avg -gt 10) {
  Write-Warning "Windows is busy. Top processes by CPU time:"
  Get-Process | Sort-Object CPU -Descending | Select-Object -First 8 Name, Id, CPU | Format-Table -AutoSize
}

Write-Host ""
Write-Host "Manual steps (cannot be scripted reliably):"
Write-Host "  - Settings > Windows Update > Pause updates (1 week)"
Write-Host "  - close browser, Discord, IDE, OneDrive sync, games/launchers"
Write-Host "  - do not use the laptop while measurements run"
Write-Host "Afterwards: .\stabilize_windows.ps1 -Restore"
