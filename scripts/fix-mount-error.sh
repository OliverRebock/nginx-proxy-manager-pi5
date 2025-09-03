#!/bin/bash

# Quick Fix für Read-Only Mount Fehler
# Kopiert Basic Auth Datei ins richtige Verzeichnis

echo "🔧 Quick Fix für Docker Mount Problem..."

# Erstelle data/nginx/custom Verzeichnis
mkdir -p ./data/nginx/custom

# Kopiere .htpasswd falls vorhanden
if [ -f "./nginx-config/custom/.htpasswd" ]; then
    echo "📁 Kopiere Basic Auth Datei..."
    cp ./nginx-config/custom/.htpasswd ./data/nginx/custom/.htpasswd
    chmod 644 ./data/nginx/custom/.htpasswd
    echo "✅ Basic Auth Datei kopiert nach ./data/nginx/custom/.htpasswd"
else
    echo "ℹ️ Keine Basic Auth Datei gefunden, wird beim ersten Start erstellt."
fi

# Container neu starten
echo "🔄 Starte Container neu..."
docker compose down
sleep 2
docker compose up -d

echo ""
echo "✅ Fix angewendet!"
echo "📋 Container Status:"
docker compose ps
