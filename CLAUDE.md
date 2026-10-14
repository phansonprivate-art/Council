# Council

Claude-Code-Skill `/council`: Vier Rollen bewerten eine Idee, jede in einer eigenen, sichtbaren Claude-Session (Windows Terminal, 4 Panes).

## Ablauf

1. `SKILL.md` (läuft im Chat) schreibt die Idee nach `.council-idea.txt` und ruft `new-session.ps1` auf. Das Skript legt `output/<SESSION>/` mit `input.md` und das Protokoll `logs/<SESSION>.md` an.
2. `launch.ps1` startet `run-role.ps1` viermal (believer, skeptic, investor, judge).
3. Believer, Skeptic und Investor schreiben parallel `<rolle>/round1.md` und danach den Marker `DONE1`. Sie lesen die Dateien der anderen bewusst **nicht**, damit die Analysen unabhängig bleiben.
4. Der Judge wartet in `run-role.ps1` auf alle drei `DONE1`, startet dann, schreibt `judge/verdict.md` und den Marker `judge/DONE`.
5. `SKILL.md` wartet per Polling auf `judge/DONE` (oder eine Datei `FAILED`), zeigt das Urteil und schließt das Protokoll ab.

## Dateien

- `skill/council/` ist die **Quelle**. Installiert wird nach `~/.claude/skills/council/` mit `./install.ps1`. Nach jeder Änderung hier neu installieren, sonst läuft die alte Version.
- `skill/council/config/<rolle>.md`: Rollenbeschreibungen. Die Arbeitsanweisungen, Formate und Marker stehen in `run-role.ps1`.
- `workspace.txt` wird von `install.ps1` nur im installierten Skill angelegt (Ablageort für `output/` und `logs/`). Reihenfolge: `COUNCIL_HOME` → `workspace.txt` → `~/council`.
- `output/` und `logs/` sind Laufzeitdaten und in `.gitignore`.

## Konventionen

- Die `.ps1`-Dateien sind UTF-8 **mit BOM**. Windows PowerShell 5.1 liest sie sonst als ANSI und zerstört die Umlaute in den Prompts. Beim Bearbeiten die BOM erhalten.
- Die Skripte laufen unter Windows PowerShell 5.1 und PowerShell 7. Keine Syntax nur für PS 7 verwenden (`&&`, `??`, ternärer Operator).
- Lange Prompts landen in `<rolle>/prompt.md`. Die Session bekommt auf der Kommandozeile nur einen kurzen Startsatz, der auf diese Datei verweist (Quoting-Probleme vermeiden).
- Den Session-Namen und die Ordner unter `output/` legt ausschließlich `new-session.ps1` an.
- Texte, Prompts und Ausgaben sind auf Deutsch.
