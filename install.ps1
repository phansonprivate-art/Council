# Installiert den Council-Skill nach ~/.claude/skills/council
# und merkt sich diesen Ordner als Ablage für output/ und logs/.
$src = Join-Path $PSScriptRoot 'skill/council'
$dst = Join-Path $HOME '.claude/skills/council'

if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
Copy-Item $src $dst -Recurse
Set-Content (Join-Path $dst 'workspace.txt') $PSScriptRoot -Encoding UTF8

Write-Host "Skill installiert: $dst" -ForegroundColor Green
Write-Host "Ergebnisse landen in: $PSScriptRoot" -ForegroundColor Green
Write-Host "Neue Claude-Code-Session starten, dann: /council <idee>"
