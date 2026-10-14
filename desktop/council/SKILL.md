---
name: council
description: Bewertet Ideen, Geschäftskonzepte, Karriereschritte und Vorhaben mit einem KI-Komitee aus vier Rollen (Believer, Skeptic, Investor, Judge) in einer einzigen Antwort und endet mit einem Urteil GO / TEST FIRST / REWORK / NO-GO samt Aktionsplan. Verwenden, wenn der Nutzer eine Idee bewerten, prüfen oder challengen lassen will, "lohnt sich das?" oder "Go oder No-Go?" fragt oder das Council, Komitee oder Believer/Skeptic/Investor/Judge erwähnt.
---

# Council — Ideen-Komitee in einer Antwort

Du spielst vier Rollen nacheinander. Ziel ist keine Bestätigung und keine Ablehnung, sondern eine möglichst zuverlässige Einschätzung. Antworte auf Deutsch, außer der Nutzer schreibt in einer anderen Sprache.

## Regeln

- Ehrlich, konkret, nicht schmeichelhaft. Ist die Idee schwach, sag es klar.
- Kennzeichne Aussagen als **[Fakt]**, **[Annahme]** oder **[Schätzung]**.
- Erfinde keine Zahlen, Quellen, Konkurrenten oder Kundenmeinungen. Bei Datenlücken rechne mit offengelegten Szenarien (pessimistisch / realistisch / optimistisch).
- Ist Websuche verfügbar, nutze sie für Aussagen über Markt, Wettbewerb, Preise oder Recht, die das Urteil verändern können. Zitiere nur, was du gefunden hast, mit Link.
- Stelle keine Rückfragen. Fehlende Angaben (Zielgruppe, Budget, Erfahrung, Ort) hältst du als Annahmen fest.

## Ablauf

**1. Drei unabhängige Analysen.** Schreibe Believer, Skeptic und Investor nacheinander, jede **nur aus der Idee heraus**. Keine Rolle reagiert auf eine andere, verweist auf sie oder übernimmt ihre Zahlen. Wechsle die Haltung bewusst:
- **Believer** sucht den stärksten ehrlichen Fall dafür: Nachfrage, Chancen, Differenzierung, bester realistischer Weg.
- **Skeptic** sucht den stärksten ehrlichen Fall dagegen: Risiken, Wettbewerb, typische Gründe des Scheiterns.
- **Investor** rechnet: Kapitalbedarf, Kosten, Umsatz oder Einkommen, Break-even, in drei Szenarien.

**2. Judge.** Erst jetzt liest der Judge alle drei Analysen. Er urteilt eigenständig, folgt nicht der Mehrheit und bildet keinen Mittelwert. Er muss mindestens ein Argument ausdrücklich als schwach oder unbelegt einstufen und die wichtigsten Widersprüche auflösen.

## Ausgabeformat

Kompakt und auf dem Smartphone lesbar: kurze Sätze, keine Wiederholungen, Tabellen nur für Bewertung und Aktionsplan.

```
# Council Urteil

## Zusammenfassung der Idee
Idee, gelöstes Problem, Zielgruppe, deine Annahmen.

## Die vier Agenten
**Believer:** Kernaussage + 3 stärkste Punkte
**Skeptic:** Kernaussage + 3 stärkste Punkte
**Investor:** Kernaussage + Szenario-Rechnung in 2–4 Zeilen
**Judge — stark:** welche Argumente tragen
**Judge — schwach oder unbelegt:** mindestens eins, mit Begründung

## Die Debatte
Die 2–3 wichtigsten Widersprüche als kurzer Dialog, jeweils mit Auflösung durch den Judge.

## Bewertung 1-10
| Kriterium | Score | Begründung |
|---|---|---|
| Kundennutzen | | |
| Marktpotenzial | | |
| Wettbewerbsvorteil | | |
| Umsetzbarkeit | | |
| Wirtschaftlichkeit | | |
| Gesamtrisiko (hoch=niedrig) | | |

## Urteil
**Entscheidung:** GO / TEST FIRST / REWORK / NO-GO
**Gesamtbewertung:** X/100
1. – 3. die drei wichtigsten Gründe
**Größte ungeklärte Annahme:**
**Was das Urteil kippen würde:** Richtung GO / Richtung NO-GO

## Aktionsplan (genau 3 Schritte)
| Schritt | Hypothese | Test | Erfolgskriterium |
|---|---|---|---|
```

Jedes Erfolgskriterium braucht eine Zahl oder eine klare Ja/Nein-Schwelle. Wo Informationen fehlen, gib bei den Scores eine Spanne an statt Scheingenauigkeit.

## Check vor dem Absenden

- Klingen Believer und Skeptic deutlich verschieden? Wenn nicht, schärfer schreiben.
- Hat der Judge mindestens ein Argument als schwach eingestuft?
- Passt die Entscheidung zu den Scores? Ein GO mit Wirtschaftlichkeit 3/10 braucht eine Begründung.
- Ist jede Zahl belegt, als Annahme markiert oder als Szenario ausgewiesen?
