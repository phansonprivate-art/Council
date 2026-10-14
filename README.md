# Council

Ein KI-Komitee aus vier Rollen (Believer, Skeptic, Investor, Judge) bewertet eine Idee und liefert ein Urteil GO / TEST FIRST / REWORK / NO-GO mit Aktionsplan. Jede Rolle läuft als eigene Claude-Session, sichtbar im Terminal.

## Voraussetzungen

- [Claude Code](https://claude.ai/install), eingeloggt
- PowerShell (Windows: vorinstalliert; macOS/Linux: PowerShell 7 `pwsh`)
- Empfohlen auf Windows: Windows Terminal (`winget install Microsoft.WindowsTerminal`) für die 4-Pane-Ansicht

## Installation

```powershell
git clone https://github.com/phansonprivate-art/Council.git council
cd council
./install.ps1
```

`install.ps1` kopiert `skill/council/` nach `~/.claude/skills/council/` und merkt sich diesen Ordner als Ablage für Ergebnisse. Danach eine neue Claude-Code-Session starten.

Nach Änderungen an `skill/council/` erneut `./install.ps1` ausführen.

## Nutzung

Im Claude-Code-Chat:

```
/council Ich möchte ein vietnamesisches Restaurant in Augsburg eröffnen
```

Ablauf:

1. Session `YYYY-MM-DD_<slug>` wird angelegt, die Anfrage in `logs/` protokolliert.
2. Windows Terminal öffnet 4 Panes, jede eine interaktive Claude-Session. Believer, Skeptic und Investor analysieren parallel und sehen die Analysen der anderen nicht. Sobald alle drei fertig sind, startet der Judge, liest die drei Analysen und fällt das Urteil.
3. Das Urteil erscheint im Chat und öffnet sich im Editor.

**Modell:** Alle vier Sessions laufen mit dem Modell, das im Chat per `/model` eingestellt ist.

Ohne Windows Terminal öffnen sich 4 einzelne Fenster, auf macOS/Linux laufen die Rollen headless als Hintergrundprozesse (Log je Rolle in `console.log`).

Die Sessions laufen mit eurem Standard-Berechtigungsmodus. Freigegeben sind Websuche sowie Lesen und Schreiben von Dateien.

## Claude Desktop (ohne Terminal)

In Claude Desktop gibt es kein Terminal und keine parallelen Sessions. Dafür gibt es `desktop/council/`: ein Modell spielt alle vier Rollen nacheinander in einer Antwort und liefert dasselbe Urteilsformat.

1. Claude Desktop → Einstellungen → Fähigkeiten → Skills → **Skill hochladen** → `desktop/council.zip` wählen.
2. Im Chat: „Bewerte meine Idee: …“ oder „Council: …“.

Unterschied zum Terminal-Council: Die drei Analysen sind nicht technisch voneinander getrennt, weil ein Modell sie nacheinander schreibt. Der Skill weist es an, jede Rolle nur aus der Idee heraus zu schreiben. Ganz so unabhängig wie vier getrennte Sessions ist das aber nicht.

## Ablage

```
logs/
  2026-10-15_restaurant-augsburg.md   ← Anfrage: Wortlaut, Zeitpunkt, Modell, Ergebnis
output/
  2026-10-15_restaurant-augsburg/
    input.md
    believer/  prompt.md  round1.md
    skeptic/   prompt.md  round1.md
    investor/  prompt.md  round1.md
    judge/     prompt.md  verdict.md
```

`output/` und `logs/` sind in `.gitignore`. Ergebnisse woanders ablegen: Umgebungsvariable `COUNCIL_HOME` setzen.

## Struktur

```
skill/council/
  SKILL.md        ← Skill: bereitet vor, startet, wartet, zeigt Ergebnis
  new-session.ps1 ← legt pro Anfrage genau einen Session-Ordner + Protokoll an
  launch.ps1      ← öffnet die 4 Sessions
  run-role.ps1    ← eine Rolle = eine Session (Judge wartet erst auf die anderen drei)
  config/         ← Rollenbeschreibungen, hier anpassen
install.ps1       ← Skill installieren
desktop/
  council/SKILL.md ← Variante für Claude Desktop: alle Rollen in einer Antwort
  council.zip      ← dasselbe als Upload-Datei
```
