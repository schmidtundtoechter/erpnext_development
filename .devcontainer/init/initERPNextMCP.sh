#!/bin/bash

set -e

# Go to frappe bench directory
cd /workspace/development
cd frappe-bench

# === Konfiguration ===
MCP_DIR="mcp-server"
MCP_REPO="https://github.com/rakeshgangwar/erpnext-mcp-server.git"
FRAPPE_SITE="d-code.localhost"
API_USER="Administrator"
MCP_PORT=7860

# === Schritt 1: MCP-Ordner anlegen ===
echo "> Erzeuge MCP-Unterverzeichnis: $MCP_DIR"
mkdir -p "$MCP_DIR"
pushd "$MCP_DIR" > /dev/null
MCP_ABSDIR=$(pwd)
popd > /dev/null

# === Schritt 2: MCP-Server klonen ===
if [ ! -d "$MCP_DIR/.git" ]; then
  echo "> Klone MCP-Repository"
  git clone "$MCP_REPO" "$MCP_DIR"
else
  echo "> MCP-Repository bereits vorhanden"
  git -C "$MCP_DIR" pull
fi

# === Schritt 3: Abhängigkeiten installieren ===
pushd "$MCP_DIR" > /dev/null
npm install
popd > /dev/null

# === Schritt 4: API-Zugang erstellen ===
API_KEY=
API_SECRET=

if [ -z "$API_KEY" ] || [ -z "$API_SECRET" ]; then
  echo "❌ API-Schlüssel muss für Administrator in $0 eingetragen werden"
  exit 1
fi

echo "> API-Key: $API_KEY"
echo "> API-Secret: $API_SECRET"

# === Schritt 5: MCP .env-Datei schreiben ===
cat > "$MCP_DIR/.env" <<EOF
FRAPPE_BASE_URL=http://localhost:8000
FRAPPE_API_KEY=$API_KEY
FRAPPE_API_SECRET=$API_SECRET
PORT=$MCP_PORT
EOF

echo "> .env für MCP-Server erstellt."

cat > /workspace/development/.vscode/mcp.json <<EOF
{
  "servers": {
    "erpnext": {
      "command": "node",
      "args": ["/workspace/development/frappe-bench/mcp-server/build/index.js"],
      "env": {
        "ERPNEXT_URL": "http://localhost:8000",
        "ERPNEXT_API_KEY": "$API_KEY",
        "ERPNEXT_API_SECRET": "$API_SECRET"
      }
    }
  }
}
EOF

echo "> .vscode/mcp.json für MCP-Server erstellt."

# === Schritt 6: BUILD ===
pushd "$MCP_DIR" > /dev/null
npm run build
popd > /dev/null

# === Schritt 7: Hinweis zum Starten ===
echo "✅ Setup abgeschlossen. MCP-Server starten mit:"
echo "cd $MCP_ABSDIR && npm run watch"
