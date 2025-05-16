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

## Neue ERPNext App erstellen und zu GitHub pushen

1. **Neue ERPNext App erzeugen**
- Wechsle in das Bench-Verzeichnis:
   ```bash
   cd frappe-bench
   ```
- Erstelle eine neue App mit Bench:
   ```bash
   bench new-app meine_neue_app
   ```
- Folge den Anweisungen und gib die geforderten Informationen ein.

2. **App zur Site hinzufügen**
- Installiere die App auf deiner Site (ersetze `site-name` durch den tatsächlichen Namen):
   ```bash
   bench --site site-name install-app meine_neue_app
   ```

3. **App-Verzeichnis als eigenes Git-Repository initialisieren**
- Wechsle in das App-Verzeichnis:
   ```bash
   cd apps/meine_neue_app
   ```
- Initialisiere ein neues Git-Repository:
   ```bash
   git init
   ```

4. **Mit GitHub verbinden**
- Voraussetzungen:
  - Du benötigst ein GitHub-Konto.
  - Die GitHub-Erweiterung für VS Code sollte installiert sein (empfohlen).
  - Du solltest in VS Code bei GitHub angemeldet sein.

- Erstelle ein neues Repository direkt in VS Code:
  - Öffne das App-Verzeichnis in VS Code.
  - Klicke in der Seitenleiste auf "Quellcodeverwaltung" und folge den Anweisungen zum Veröffentlichen auf GitHub.
  - Alternativ kannst du das Repository auch manuell auf [github.com](https://github.com/new) anlegen und dann das Remote hinzufügen:
    ```bash
    git remote add origin https://github.com/<dein-benutzername>/<repo-name>.git
    ```

5. **Änderungen committen und pushen**
- Füge alle Dateien zur Versionskontrolle hinzu:
   ```bash
   git add .
   ```
- Erstelle einen Commit:
   ```bash
   git commit -m "Initial commit für meine_neue_app"
   ```
- Push das Repository zu GitHub:
   ```bash
   git push -u origin main
   ```
   (Passe ggf. den Branch-Namen an.)

**Hinweis:** Stelle sicher, dass du die nötigen Zugriffsrechte für das GitHub-Repository hast.
