---
name: council
description: Bewertet Ideen, Geschäftskonzepte, Produkte und Vorhaben mit einem KI-Komitee aus vier Rollen (Believer, Skeptic, Investor, Judge). Startet vier sichtbare Claude-Sessions im Terminal: drei unabhängige Analysen, dann ein Judge, der das Urteil GO / TEST FIRST / REWORK / NO-GO mit Aktionsplan zurück in den Chat liefert. Verwenden wenn der Nutzer /council aufruft, eine Idee bewerten/validieren/challengen lassen will, nach Feedback zu einer Geschäftsidee fragt oder "lohnt sich das?" / "Go oder No-Go?" fragt.
---

# Council — Ideen-Komitee

Die Idee steht in `args`. Dieser Skill startet vier **eigene Claude-Sessions** (Windows Terminal mit 4 Panes), wartet auf das Urteil, zeigt es im Chat und öffnet es im Editor.

Du selbst analysierst die Idee **nicht** — das machen die vier Sessions. Deine Aufgabe ist Vorbereitung, Start, Warten, Ergebnis.

**Pfade:**
- `<SKILL>` = das Basisverzeichnis dieses Skills (wird beim Laden angezeigt: „Base directory for this skill").
- `<WS>` = Arbeitsverzeichnis für Ergebnisse. Ermitteln in dieser Reihenfolge: Umgebungsvariable `COUNCIL_HOME` → Inhalt von `<SKILL>/workspace.txt` → `~/council`.
- **Shell:** Windows `powershell`, macOS/Linux `pwsh` (PowerShell 7). Fehlt `pwsh`, sag dem Nutzer, dass PowerShell 7 nötig ist, und brich ab.

---

## Schritt 1: Session vorbereiten

**Lege keine Ordner oder Dateien unter `output/` oder `logs/` selbst an und baue den Session-Namen nicht selbst.** Das erledigt ausschließlich `new-session.ps1` — genau einmal pro Anfrage.

1. **Idee** aus `args`. Ist `args` leer, frage einmalig nach der Idee und warte.
2. **`<MODELL>`** = deine **exakte Modell-ID** aus deinem Systemprompt (z. B. `claude-opus-5-5`). Genau diese ID bekommen die vier Sessions.
3. **Idee übergeben:** Schreibe den vollständigen, unveränderten Text aus `args` mit dem Write-Tool nach `<WS>/.council-idea.txt`.
4. **Session anlegen** — **ein einziger Aufruf**:
   ```
   <shell> -NoProfile -ExecutionPolicy Bypass -File "<SKILL>/new-session.ps1" -IdeaFile "<WS>/.council-idea.txt" -Model "<MODELL>" -Workspace "<WS>"
   ```
   Die **letzte Ausgabezeile** ist `<SESSION>`. Das Skript legt `output/<SESSION>/` mit den vier Unterordnern und `input.md` an, schreibt das Protokoll `logs/<SESSION>.md` und löscht `.council-idea.txt`.

   Schlägt der Aufruf fehl: Fehlermeldung wörtlich weitergeben und abbrechen. **Nicht** erneut versuchen und **nicht** mit eigenem Code nachbauen.

---

## Schritt 2: Council starten

```
<shell> -NoProfile -ExecutionPolicy Bypass -File "<SKILL>/launch.ps1" -Session "<SESSION>" -Model "<MODELL>" -Workspace "<WS>"
```

Das öffnet Windows Terminal mit 4 Panes (Believer, Skeptic, Investor, Judge). Jede Rolle ist **eine interaktive Claude-Session**, sichtbar im Pane und in der Session-Liste. Believer, Skeptic und Investor analysieren parallel und unabhängig voneinander (eine Runde). Der Judge startet erst, wenn alle drei fertig sind, und urteilt über ihre drei Analysen. Den vollständigen Auftrag jeder Rolle legt das Skript in `<WS>/output/<SESSION>/<rolle>/prompt.md` ab.

Ohne Windows Terminal startet das Skript 4 einzelne Fenster, auf macOS/Linux Hintergrundprozesse (dann headless) — das ist in Ordnung.

Meldet das Skript einen Fehler, gib ihn wörtlich weiter, setze im Protokoll `Status` auf `fehlgeschlagen` und brich ab.

Chat-Meldung:
```
🏛️ Council `<SESSION>` läuft — 4 Sessions im Terminal (Modell: <MODELL>). Ich melde mich mit dem Urteil.
```

---

## Schritt 3: Auf das Urteil warten

Starte diesen Befehl mit `run_in_background: true` — du wirst benachrichtigt, sobald er endet:

```powershell
$d = "<WS>/output/<SESSION>"; $end = (Get-Date).AddMinutes(60)
while ((Get-Date) -lt $end) {
  if (Test-Path "$d/judge/DONE") { "DONE"; exit 0 }
  $f = Get-ChildItem $d -Recurse -File -Filter FAILED -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($f) { "FAILED: $($f.FullName) — $(Get-Content $f.FullName -Raw)"; exit 1 }
  Start-Sleep 15
}
"TIMEOUT"; exit 2
```

Während du wartest, nichts weiter tun. Fragt der Nutzer nach dem Stand, liste die vorhandenen Marker (`DONE1`, `DONE`) in `<WS>/output/<SESSION>/*/`:
- `DONE1` bei allen drei Rollen → Analysen fertig, Judge arbeitet
- `judge/DONE` → Urteil fertig

**Bei `FAILED`:** Nenne die Rolle und den Grund, Protokoll-Status → `fehlgeschlagen`, Ende.
**Bei `TIMEOUT`:** Melde den Stand der Marker und frage, ob weiter gewartet werden soll.

---

## Schritt 4: Ergebnis

1. Lies `<WS>/output/<SESSION>/judge/verdict.md` und gib den **vollständigen Inhalt** im Chat aus.
2. **Datei im Editor öffnen:** `code "<WS>/output/<SESSION>/judge/verdict.md"`. Schlägt das fehl: Windows `Start-Process "<pfad>"`, macOS `open "<pfad>"`, Linux `xdg-open "<pfad>"`. Klappt nichts, nur den Pfad nennen.
3. **Protokoll abschließen** in `<WS>/logs/<SESSION>.md`: `Status` → `abgeschlossen`, unter `## Ergebnis` Entscheidung, Gesamtbewertung, ein Satz Begründung und der Pfad `output/<SESSION>/judge/verdict.md`.
4. Abschluss:
   ```
   📂 Urteil geöffnet · output/<SESSION>/ · Protokoll: logs/<SESSION>.md
   ```
