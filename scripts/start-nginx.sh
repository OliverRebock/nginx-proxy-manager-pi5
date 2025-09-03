#!/bin/bash

# Schnelles Post-Reboot Setup für bereits vorbereiteten Pi
# Führe dieses Script nach dem Neustart aus

echo "🚀 Starte Nginx Proxy Manager..."

# Überprüfe Docker Installation
if ! command -v docker &> /dev/null; then
    echo "❌ Docker ist nicht installiert oder nicht im PATH!"
    echo "Führe zuerst pi-full-setup.sh aus."
    exit 1
fi

# Überprüfe Docker Berechtigung
if ! docker ps &> /dev/null; then
    echo "❌ Docker Berechtigung fehlt!"
    echo "Möglicherweise ist ein Neustart erforderlich oder du musst dich neu anmelden."
    echo "Versuche: sudo docker ps"
    exit 1
fi

echo "✅ Docker ist bereit!"

# Überprüfe ob wir im richtigen Verzeichnis sind
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml nicht gefunden!"
    echo "Bitte führe das Script aus dem Projektverzeichnis aus."
    exit 1
fi

# Ziehe neueste Images
echo "📦 Ziehe neueste Docker Images..."
docker compose pull

# Starte Container
echo "🚀 Starte Nginx Proxy Manager Container..."
docker compose up -d

# Warte und prüfe Status
echo "⏳ Warte auf Container Start..."
sleep 10

# Zeige Status
echo "📊 Container Status:"
docker compose ps

# Zeige Logs
echo ""
echo "📋 Container Logs (drücke Ctrl+C zum Beenden):"
echo "Warte ca. 30-60 Sekunden bis 'Nginx Proxy Manager is running' erscheint..."
echo ""

# Verfolge Logs für 30 Sekunden
timeout 30 docker compose logs -f nginx-proxy-manager || true

echo ""
echo "=================================================================="
echo "🎉 NGINX PROXY MANAGER IST BEREIT!"
echo "=================================================================="
echo ""
echo "🌐 Zugriff über:"
echo "   - Intern:  https://chef.fritz.box"
echo "   - Extern:  https://myhomeassi23.ddns.net"
echo "   - Fallback: http://$(hostname -I | awk '{print $1}'):81"
echo ""
echo "🔐 Standard Login:"
echo "   Email: admin@example.com"
echo "   Passwort: changeme"
echo ""
echo "⚠️  WICHTIG:"
echo "   1. SOFORT Passwort ändern!"
echo "   2. Let's Encrypt für myhomeassi23.ddns.net einrichten"
echo "   3. Router Ports 80 und 443 weiterleiten"
echo ""
echo "📊 Nützliche Befehle:"
echo "   docker compose logs -f          # Live Logs"
echo "   docker compose ps               # Status"
echo "   docker compose restart          # Neustart"
echo "   docker compose down             # Stoppen"
echo ""
