# ERPNext Development

Dieses Repository enthält eine vorkonfigurierte Entwicklungsumgebung für ERPNext mit Devcontainer-Support.

## Voraussetzungen

- Docker
- Visual Studio Code
- Erweiterung: "Dev Containers" (bzw. "Remote - Containers")

## Devcontainer starten

1. Repository in VS Code öffnen.
2. Über die Command Palette `Dev Containers: Reopen in Container` wählen.

Nach dem Öffnen des Containers befindest du dich automatisch im richtigen Arbeitsverzeichnis.

## Bench initialisieren

1. Führe im Container das Skript `~/initBench.sh` aus:

   ```bash
   ~/initBench.sh
   ```

2. Während des Setups wirst du nach einigen Eingaben gefragt:

   - SQL Root Passwort: `123`
   - Administrator-Passwort: `admin`

   Das Setup richtet die Bench-Instanz automatisch ein.

3. Navigiere nach Abschluss in das Bench-Verzeichnis:

   ```bash
   cd frappe-bench
   ```

4. Starte die Bench:

   ```bash
   bench start
   ```

## Zugriff auf ERPNext im Browser

Öffne im Browser die URL:

```
http://d-code.localhost:8000/
```

   - Administrator-Name: `Administrator`
   - Administrator-Passwort: `admin`

> Hinweis: Stelle sicher, dass deine Hosts-Datei oder ein lokaler DNS-Eintrag "d-code.localhost" auf `127.0.0.1` zeigt. In der Regel funktioniert das aber bereits so.

## Ersteinrichtung von ERPNext

Beim ersten Aufruf wirst du durch die Ersteinrichtung geführt. Gib folgende Informationen ein:

1. **Sprache** und **Zeitzone** auswählen
2. **Firmenname**: z. B. `Deine GmbH`
3. **Land**: z. B. `Germany`
4. **Währung**: `EUR`
5. **Demo-daten generiene** Ja/Nein

Danach ist dein ERPNext-Server einsatzbereit und du kannst mit der Entwicklung beginnen.