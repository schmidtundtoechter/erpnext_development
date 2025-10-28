# Frappe Development Container Setup

Dieses README beschreibt die notwendigen Schritte nach dem Start des Development Containers.

> **📁 Script-Organisation:** Alle Shell-Scripts (*.sh) und Aliases befinden sich im `init/` Verzeichnis für bessere Organisation.

## 📋 Quick Start Guide

Nach dem Container-Start müssen folgende Scripts in **dieser Reihenfolge** ausgeführt werden:

### 1. 🏗️ Frappe Bench initialisieren

```bash
~/initBench.sh
```

**Was passiert:**
- Erstellt Frappe Bench mit Version 15
- Konfiguriert PostgreSQL und Redis-Verbindungen
- Erstellt Site `d-code.localhost` mit PostgreSQL
- Aktiviert Developer-Mode

**Dauer:** ~5-10 Minuten

### 2. initERPNextMCP.sh

**Zweck:** Installiert und konfiguriert den ERPNext MCP-Server für die Integration mit GitHub Copilot.

**Was passiert:**
- Erstellt Symlink zu mcp_servers (`/workspace/development/mcp_servers`)
- Klont den ERPNext MCP-Server in `frappe-bench/mcp-server/`

**Dauer:** ~2-3 Minuten

### 3. 📦 My App installieren

```bash
cd /workspace/development/frappe-bench
~/installApp.sh git@github.com/mkt1/myapp.git
```

**Was passiert:**
- ✅ Validiert Verzeichnis und Repository-URL
- 🔍 Überprüft ob bench läuft (muss gestoppt sein)
- 📥 Lädt die My-App herunter
- 📦 Installiert App auf der Site
- 🔄 Führt Datenbank-Migration aus
- 🏗️  Erstellt Assets neu

**Ausgabe:** Farbige Emojis und detaillierte Fortschrittsanzeige

**Dauer:** ~3-5 Minuten

## 🚀 Nach der Installation

### Frappe starten:
```bash
cd /workspace/development/frappe-bench
bench start
```

### Zugang:
- **URL:** http://d-code.localhost:8000
- **Admin:** Administrator
- **Passwort:** admin

## 📂 Wichtige Verzeichnisse

```
/home/frappe/                   # Home-Verzeichnis
├── initBench.sh               # Bench-Initialisierung
├── initERPNextMCP.sh          # MCP-Setup
└── installApp.sh              # App-Installation

/workspace/development/         # Entwicklungsbereich
├── frappe_development/        # Der framework container code
│   └── .devcontainer/
│       └── init/              # Alle Shell-Scripts
│           ├── initBench.sh
│           ├── initERPNextMCP.sh
│           ├── installApp.sh
│           ├── fix-git-refs.sh
│           └── aliases.sh
└── frappe-bench/              # Frappe Bench
    ├── apps/                  # Installierte Apps
    ├── sites/                 # Site-Konfiguration
    └── logs/                  # Log-Dateien
```

## 🔧 Troubleshooting

### Script-Berechtigungen prüfen:
```bash
ls -la ~/init*.sh ~/install*.sh
```

### installApp.sh ohne Parameter testen:
```bash
cd /workspace/development/frappe-bench
~/installApp.sh
# Zeigt Hilfe-Nachricht mit korrekter Syntax
```

### Logs anzeigen:
```bash
# Frappe Logs
tail -f /workspace/development/frappe-bench/logs/bench.log

# PostgreSQL-Verbindung testen
PGPASSWORD=123 psql -h postgres -U postgres -c "SELECT version();"
```

### Container neu starten:
```bash
# Im Host-System (.devcontainer Verzeichnis)
docker-compose restart frappe
```

### Komplette Neu-Installation:
```bash
# Volumes löschen und neu starten
docker-compose down -v
docker-compose up -d
```

## 💡 Entwicklung

### Code-Änderungen:
- App-Code liegt in `/workspace/development/frappe-bench/apps/myapp/`
- Änderungen werden automatisch erkannt (Developer-Mode)
- Bei Bedarf: `bench restart`

### Neue DocTypes/Features:
```bash
cd /workspace/development/frappe-bench
bench --site d-code.localhost migrate
bench --site d-code.localhost clear-cache
```

### Datenbank-Zugriff:
```bash
# PostgreSQL Console  
PGPASSWORD=123 psql -h postgres -U postgres -d d_code_localhost

# Oder direkt:
docker exec -it devcontainer-postgres-1 psql -U postgres
```

## 🏃‍♂️ Schnellstart (Ein-Befehl):

```bash
# Alles in einem Durchgang (dauert ~15 Minuten)
~/initBench.sh && \
~/initERPNextMCP.sh && \
cd /workspace/development/frappe-bench && \
~/installApp.sh https://github.com/mkt1/myapp.git
```

---

**Status-Check:** Alle Scripts erfolgreich? → `bench start` und http://d-code.localhost:8000 öffnen! 🎉
