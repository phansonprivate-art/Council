# Legt GENAU EINE Session an: output/<Session>/ mit believer, skeptic, investor, judge + input.md,
# dazu das Protokoll logs/<Session>.md. Gibt als letzte Zeile den Session-Namen aus.
# Nutzung: new-session.ps1 -IdeaFile <datei mit der Idee> [-Model <id>] [-Workspace <pfad>]
param(
  [Parameter(Mandatory)][string]$IdeaFile,
  [string]$Model = "",
  [string]$Workspace = ""
)
$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false)

# Workspace: Parameter > COUNCIL_HOME > workspace.txt (von install.ps1) > ~/council
if (-not $Workspace) {
  $wsFile = Join-Path $PSScriptRoot 'workspace.txt'
  if ($env:COUNCIL_HOME) { $Workspace = $env:COUNCIL_HOME }
  elseif (Test-Path $wsFile) { $Workspace = (Get-Content $wsFile -Raw).Trim() }
  else { $Workspace = Join-Path $HOME 'council' }
}

if (-not (Test-Path $IdeaFile)) { Write-Host "Ideen-Datei fehlt: $IdeaFile" -ForegroundColor Red; exit 1 }
$idea = [IO.File]::ReadAllText((Resolve-Path $IdeaFile).Path, [Text.Encoding]::UTF8).Trim()
if (-not $idea) { Write-Host "Die Idee ist leer." -ForegroundColor Red; exit 1 }

# --- Session-Name: YYYY-MM-DD_<slug> ---
$stop = @(
  'ich','du','er','sie','wir','ihr','man','es','mir','mich','mein','meine','meinen','unser','unsere',
  'ein','eine','einen','einem','einer','der','die','das','den','dem','des',
  'moechte','moechten','will','wollen','soll','sollte','wuerde','wuerden','kann','koennte','gerne','bitte','einfach',
  'und','oder','aber','dass','wie','was','so','als','auch','noch','ist','sind',
  'in','im','am','an','auf','aus','bei','mit','nach','von','vom','zu','zum','zur','fuer','ueber','unter','vor','durch'
)
$clean = $idea.ToLower() -replace 'ä','ae' -replace 'ö','oe' -replace 'ü','ue' -replace 'ß','ss'
$clean = $clean -replace '[^a-z0-9]+', ' '
$words = @($clean.Split(' ', [StringSplitOptions]::RemoveEmptyEntries) |
  Where-Object { $_.Length -gt 1 -and $stop -notcontains $_ } |
  Select-Object -First 4)
if ($words.Count -eq 0) { $words = @('idee') }
$slug = $words -join '-'
if ($slug.Length -gt 50) { $slug = $slug.Substring(0, 50).TrimEnd('-') }

$date = Get-Date -Format 'yyyy-MM-dd'
$now = Get-Date -Format 'yyyy-MM-dd HH:mm'
$outRoot = Join-Path $Workspace 'output'
$session = "${date}_$slug"
$i = 2
while (Test-Path (Join-Path $outRoot $session)) { $session = "${date}_$slug-v$i"; $i++ }

# --- Anlegen: ein Ordner, vier Unterordner ---
$out = Join-Path $outRoot $session
foreach ($r in 'believer','skeptic','investor','judge') {
  New-Item -ItemType Directory -Force (Join-Path $out $r) | Out-Null
}
[IO.File]::WriteAllText((Join-Path $out 'input.md'), "# Idee`n`n$idea`n", $utf8)

$logs = Join-Path $Workspace 'logs'
New-Item -ItemType Directory -Force $logs | Out-Null
$modelText = if ($Model) { $Model } else { 'CLI-Standard' }
$log = @"
# Council-Anfrage

| Feld | Wert |
|---|---|
| Session | $session |
| Zeitpunkt | $now |
| Modell | $modelText |
| Status | läuft |

## Wortlaut der Anfrage

$idea

## Ergebnis

_wird nach Abschluss ergänzt_
"@
[IO.File]::WriteAllText((Join-Path $logs "$session.md"), $log, $utf8)

Remove-Item $IdeaFile -Force -ErrorAction SilentlyContinue
Write-Output $session
