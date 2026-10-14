# Startet das Council für eine vorbereitete Session (output/<Session>/input.md muss existieren).
# Windows Terminal vorhanden -> 4 Panes (2x2). Sonst: 4 eigene Fenster (Windows) bzw. Hintergrundprozesse (macOS/Linux).
# Nutzung: launch.ps1 -Session 2026-10-14_meine-idee [-Model claude-opus-5-5] [-Workspace <pfad>]
param(
  [Parameter(Mandatory)][string]$Session,
  [string]$Model = "",
  [string]$Workspace = ""
)

# Workspace: Parameter > COUNCIL_HOME > workspace.txt (von install.ps1) > ~/council
if (-not $Workspace) {
  $wsFile = Join-Path $PSScriptRoot 'workspace.txt'
  if ($env:COUNCIL_HOME) { $Workspace = $env:COUNCIL_HOME }
  elseif (Test-Path $wsFile) { $Workspace = (Get-Content $wsFile -Raw).Trim() }
  else { $Workspace = Join-Path $HOME 'council' }
}

$out = Join-Path $Workspace "output/$Session"
if (-not (Test-Path (Join-Path $out 'input.md'))) {
  Write-Host "Fehlt: $out/input.md" -ForegroundColor Red
  exit 1
}

$roles = 'believer','skeptic','investor','judge'
foreach ($r in $roles) { New-Item -ItemType Directory -Force (Join-Path $out $r) | Out-Null }

# Marker alter Läufe entfernen
Get-ChildItem $out -Recurse -File -Include DONE,DONE1,FAILED -ErrorAction SilentlyContinue | Remove-Item -Force

$script = Join-Path $PSScriptRoot 'run-role.ps1'
$shell = (Get-Process -Id $PID).Path

function RoleArgs([string]$r, [bool]$keepOpen = $true) {
  $a = @()
  if ($keepOpen) { $a += '-NoExit' }
  $a += @('-ExecutionPolicy','Bypass','-File',$script,'-Role',$r,'-Session',$Session,'-Workspace',$Workspace)
  if ($Model) { $a += @('-Model',$Model) }
  if (-not $keepOpen) { $a += '-Headless' }
  return $a
}

if (Get-Command wt -ErrorAction SilentlyContinue) {
  $mode = 'Windows Terminal (4 Panes)'
  $a = @('new-tab','--title','Believer',$shell) + (RoleArgs believer)
  $a += ';'; $a += @('split-pane','-V','--title','Skeptic',$shell) + (RoleArgs skeptic)
  $a += ';'; $a += @('move-focus','left')
  $a += ';'; $a += @('split-pane','-H','--title','Investor',$shell) + (RoleArgs investor)
  $a += ';'; $a += @('move-focus','right')
  $a += ';'; $a += @('split-pane','-H','--title','Judge',$shell) + (RoleArgs judge)
  & wt @a
}
elseif ($env:OS -eq 'Windows_NT') {
  $mode = '4 PowerShell-Fenster'
  foreach ($r in $roles) { Start-Process $shell -ArgumentList (RoleArgs $r) }
}
else {
  $mode = 'Hintergrundprozesse'
  foreach ($r in $roles) {
    $log = Join-Path (Join-Path $out $r) 'console.log'
    Start-Process $shell -ArgumentList (RoleArgs $r $false) -RedirectStandardOutput $log
  }
}

Write-Host "Council gestartet ($mode) -> $out" -ForegroundColor Cyan
