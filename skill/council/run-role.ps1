param(
  [Parameter(Mandatory)][ValidateSet('believer','skeptic','investor','judge')][string]$Role,
  [Parameter(Mandatory)][string]$Session,
  [Parameter(Mandatory)][string]$Workspace,
  [string]$Model = "",
  [switch]$Headless   # ohne Terminalfenster (macOS/Linux-Hintergrundmodus): claude -p statt interaktiv
)
# Eine Rolle = eine interaktive Claude-Session (sichtbar im Pane und in der Session-Liste).
# Believer/Skeptic/Investor: eine unabhängige Analyse, dann DONE1.
# Judge: das Skript wartet auf DONE1 aller drei, dann startet die Judge-Session.
$utf8 = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = $utf8
try { [Console]::OutputEncoding = $utf8 } catch {}
try { $Host.UI.RawUI.WindowTitle = "Council: $Role" } catch {}

Set-Location $Workspace
$abs = (Resolve-Path (Join-Path $Workspace "output/$Session")).Path
function P([string]$r, [string]$n) { Join-Path (Join-Path $abs $r) $n }
New-Item -ItemType Directory -Force (Join-Path $abs $Role) | Out-Null

# --- claude binary ---
$claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
if (-not $claude) {
  foreach ($c in 'claude.exe','claude') {
    $p = Join-Path $HOME ".local/bin/$c"
    if (Test-Path $p) { $claude = $p; break }
  }
}
if (-not $claude) {
  $claude = Get-ChildItem (Join-Path $HOME '.vscode/extensions') -Directory -Filter 'anthropic.claude-code-*' -ErrorAction SilentlyContinue |
    Sort-Object { [version]($_.Name -replace '^anthropic\.claude-code-([\d.]+).*','$1') } |
    ForEach-Object { Get-ChildItem (Join-Path $_.FullName 'resources/native-binary') -File -Filter 'claude*' -ErrorAction SilentlyContinue } |
    Select-Object -Last 1 -ExpandProperty FullName
}
if (-not $claude) {
  Write-Host "claude nicht gefunden. Installieren: https://claude.ai/install" -ForegroundColor Red
  Set-Content (P $Role 'FAILED') 'claude nicht gefunden'
  return
}

$flags = @('--allowedTools', 'WebSearch,WebFetch,Read,Write,Edit,Glob,Grep')
if ($Model) { $flags += @('--model', $Model) }

# --- Eingaben ---
$rolePrompt = Get-Content (Join-Path $PSScriptRoot "config/$Role.md") -Raw -Encoding UTF8
$idea = (Get-Content (Join-Path $abs 'input.md') -Raw -Encoding UTF8)
$ideaShort = (($idea -replace '^#\s*Idee\s*', '') -replace '["\r\n]', ' ').Trim()
if ($ideaShort.Length -gt 80) { $ideaShort = $ideaShort.Substring(0, 80) + '...' }

$tabelle = @"
| Kriterium | Score | Begründung |
|---|---|---|
| Kundennutzen | | |
| Marktpotenzial | | |
| Wettbewerbsvorteil | | |
| Umsetzbarkeit | | |
| Wirtschaftlichkeit | | |
| Gesamtrisiko (hoch=niedrig) | | |
"@

$regeln = @"
REGELN:
- Antworte auf Deutsch. Ehrlich, konkret, nicht schmeichelhaft.
- Kennzeichne Fakten / Annahmen / Spekulationen.
- Erfinde keine Zahlen oder Quellen. Bei Datenlücken: transparente Szenarien (pessimistisch / realistisch / optimistisch).
- Nutze WebSearch, wenn Markt, Wettbewerb, Preise, Standort oder Recht das Urteil verändern können. Zitiere nur Gefundenes.
- Schreibe jede Ergebnisdatei in EINEM Write-Aufruf.
"@

if ($Role -eq 'judge') {
  $files = @('believer','skeptic','investor') | ForEach-Object { P $_ DONE1 }
  while (@($files | Where-Object { -not (Test-Path $_) }).Count -gt 0) {
    $n = @($files | Where-Object { Test-Path $_ }).Count
    Write-Host "[judge] warte auf die drei Analysen ($n/3 fertig) ..." -ForegroundColor DarkGray
    Start-Sleep 10
  }

  $prompt = @"
$rolePrompt

IDEE:
$idea

$regeln

AUFGABE:
Lies die drei unabhängigen Analysen:
$(P believer round1.md)
$(P skeptic round1.md)
$(P investor round1.md)

Stufe mindestens ein Argument ausdrücklich als schwach oder unbelegt ein. Löse Widersprüche auf.
Folge nicht automatisch der Mehrheit. Prüfe zentrale Zahlen, bei Bedarf per WebSearch.
Das Urteil muss zu den Einzelbewertungen passen.

Schreibe das Urteil nach: $(P judge verdict.md)
Halte dich EXAKT an dieses Format (kompakt, smartphone-tauglich):

# Council Urteil

## Zusammenfassung der Idee
Was ist die Idee, welches Problem löst sie, wer ist die Zielgruppe, inklusive deiner Annahmen.

## Die vier Agenten
Believer / Skeptic / Investor je mit Kernaussage und stärksten Punkten.
Judge: welche Argumente waren stark, welche schwach oder unbelegt.

## Die Debatte
Wo widersprechen sich die drei Analysen? Als kurzer Dialog, mit deiner Auflösung.

## Bewertung 1-10
$tabelle

## Urteil
**Entscheidung:** GO / TEST FIRST / REWORK / NO-GO
**Gesamtbewertung:** X/100
Die drei wichtigsten Gründe (nummeriert)
**Größte ungeklärte Annahme:**
**Was das Urteil kippen würde:**

## Aktionsplan (genau 3 Schritte)
| Schritt | Hypothese | Test | Erfolgskriterium |
|---|---|---|---|

Lege GANZ ZUM SCHLUSS die leere Datei an: $(P judge DONE)
Bestätige danach kurz und beende deine Arbeit.
"@
}
else {
  $prompt = @"
$rolePrompt

IDEE:
$idea

$regeln

Du bist eine von drei parallel laufenden Sessions (believer, skeptic, investor).
Analysiere die Idee ausschließlich aus deiner Rolle heraus. Lies KEINE Dateien der anderen Rollen.
Schreibe nach: $(P $Role round1.md)

Format:
# $Role
## Kernaussage
(1-2 Sätze)
## Die drei stärksten Punkte
## Chancen bzw. Risiken
## Annahmen
## Bewertung 1-10
$tabelle

Lege GANZ ZUM SCHLUSS die leere Datei an: $(P $Role DONE1)
Bestätige danach kurz und beende deine Arbeit. Das Urteil fällt der Judge.
"@
}

# Vollständigen Auftrag ablegen und der Session nur einen kurzen Einstieg übergeben:
# lange Prompts auf der Kommandozeile scheitern sonst am Quoting.
$promptFile = P $Role 'prompt.md'
[IO.File]::WriteAllText($promptFile, $prompt, $utf8)

$names = @{ believer = 'THE BELIEVER'; skeptic = 'THE SKEPTIC'; investor = 'THE INVESTOR'; judge = 'THE JUDGE' }
$start = "Du bist $($names[$Role]) im Council-Komitee zur Idee: $ideaShort - Lies deinen vollständigen Auftrag in $promptFile und führe ihn komplett aus."

Write-Host "[$Role] Modell: $(if ($Model) { $Model } else { 'CLI-Standard' })" -ForegroundColor DarkGray
if ($Headless) {
  $start | & $claude -p --permission-mode acceptEdits @flags
} else {
  & $claude @flags $start
}
