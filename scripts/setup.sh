#!/bin/bash

# Setup Script für Nginx Proxy Manager auf bereits vorbereiteten Raspberry Pi 5
# Verwende pi-full-setup.sh für frische Pi Installation!
# Dieses Script erstellt nur die Verzeichnisse und Konfigurationen

echo "=== Nginx Proxy Manager Setup für vorbereiteten Raspberry Pi 5 ==="
echo "⚠️  Für frische Pi Installation verwende: ./scripts/pi-full-setup.sh"
echo ""

# Erstelle notwendige Verzeichnisse
echo "Erstelle Verzeichnisse..."
mkdir -p ./config/nginx
mkdir -p ./config/letsencrypt
mkdir -p ./data
mkdir -p ./nginx-config/ssl

# Setze korrekte Berechtigungen
echo "Setze Berechtigungen..."
chmod 755 ./config
chmod 755 ./data
chmod 755 ./nginx-config

# Erstelle Basic Auth Datei (Benutzername: admin, Passwort wird abgefragt)
echo "Erstelle Basic Auth..."
if ! command -v htpasswd &> /dev/null; then
    echo "htpasswd ist nicht installiert. Installiere apache2-utils..."
    sudo apt-get update
    sudo apt-get install -y apache2-utils
fi

echo "Bitte gib ein Passwort für den Admin-Benutzer ein:"
htpasswd -c ./nginx-config/.htpasswd admin

# Erstelle selbstsignierte Zertifikate für interne Domain
echo "Erstelle selbstsignierte SSL-Zertifikate für chef.fritz.box..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./nginx-config/ssl/chef.fritz.box.key \
    -out ./nginx-config/ssl/chef.fritz.box.crt \
    -subj "/C=DE/ST=Germany/L=Home/O=HomeNetwork/OU=IT/CN=chef.fritz.box/emailAddress=admin@chef.fritz.box"

# Setze Berechtigungen für SSL-Dateien
chmod 600 ./nginx-config/ssl/chef.fritz.box.key
chmod 644 ./nginx-config/ssl/chef.fritz.box.crt

echo "=== Setup abgeschlossen! ==="
echo ""
echo "Nächste Schritte:"
echo "1. Starte den Container: docker-compose up -d"
echo "2. Warte 30-60 Sekunden bis der Service bereit ist"
echo "3. Öffne https://chef.fritz.box oder https://myhomeassi23.ddns.net"
echo "4. Standard Login: admin@example.com / changeme"
echo "5. WICHTIG: Ändere sofort das Standard-Passwort!"
echo ""
echo "Für Let's Encrypt Zertifikate konfiguriere im Nginx Proxy Manager:"
echo "- Domain: myhomeassi23.ddns.net"
echo "- Aktiviere 'Force SSL' und 'HTTP/2 Support'"
