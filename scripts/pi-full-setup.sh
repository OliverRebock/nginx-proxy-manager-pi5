#!/bin/bash

# Vollständiges Setup Script für Nginx Proxy Manager auf frisch installiertem Raspberry Pi 5
# Dieses Script installiert alle Abhängigkeiten und richtet das System ein

echo "=================================================================="
echo "=== Nginx Proxy Manager Setup für frischen Raspberry Pi 5 ==="
echo "=================================================================="

# Aktuelles Verzeichnis speichern
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Script läuft von: $SCRIPT_DIR"
echo "Projekt Verzeichnis: $PROJECT_DIR"
echo ""

# System aktualisieren
echo "🔄 System wird aktualisiert..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Grundlegende Tools installieren
echo "🛠️ Installiere grundlegende Tools..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    nano \
    htop \
    unzip \
    apache2-utils \
    openssl \
    ca-certificates \
    gnupg \
    lsb-release

# Docker Repository hinzufügen
echo "🐳 Füge Docker Repository hinzu..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker installieren
echo "🐳 Installiere Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Benutzer zur Docker Gruppe hinzufügen
echo "👤 Füge Benutzer '$USER' zur Docker Gruppe hinzu..."
sudo usermod -aG docker $USER

# Docker Service starten und aktivieren
echo "🚀 Starte Docker Service..."
sudo systemctl start docker
sudo systemctl enable docker

# Überprüfe Docker Installation
echo "✅ Überprüfe Docker Installation..."
sudo docker --version
sudo docker compose version

echo ""
echo "=================================================================="
echo "=== NGINX PROXY MANAGER KONFIGURATION ==="
echo "=================================================================="

# Wechsle ins Projektverzeichnis
cd "$PROJECT_DIR"

# Erstelle notwendige Verzeichnisse
echo "📁 Erstelle Verzeichnisse..."
mkdir -p ./config/nginx
mkdir -p ./config/letsencrypt
mkdir -p ./data
mkdir -p ./nginx-config/custom

# Setze korrekte Berechtigungen
echo "🔐 Setze Berechtigungen..."
chmod 755 ./config
chmod 755 ./data
chmod 755 ./nginx-config

# Erstelle Basic Auth Datei
echo ""
echo "🔒 Basic Authentication einrichten..."
echo "Für zusätzliche Sicherheit wird ein Basic Auth Passwort benötigt."
echo "Benutzername: admin"

# Verbesserte Passwort-Eingabe mit Retry-Logik
auth_success=false
retry_count=0
max_retries=3

while [ "$auth_success" = false ] && [ $retry_count -lt $max_retries ]; do
    echo ""
    echo "Versuch $((retry_count + 1)) von $max_retries"
    echo "Bitte gib ein sicheres Passwort ein (mindestens 8 Zeichen):"
    
    # Passwort ohne Echo eingeben
    read -s -p "Passwort: " password1
    echo ""
    read -s -p "Passwort wiederholen: " password2
    echo ""
    
    # Passwörter vergleichen
    if [ "$password1" != "$password2" ]; then
        echo "❌ Passwörter stimmen nicht überein!"
        retry_count=$((retry_count + 1))
        continue
    fi
    
    # Passwort-Länge prüfen
    if [ ${#password1} -lt 8 ]; then
        echo "❌ Passwort muss mindestens 8 Zeichen haben!"
        retry_count=$((retry_count + 1))
        continue
    fi
    
    # htpasswd mit Passwort aus Variable
    if echo "$password1" | htpasswd -c -i ./nginx-config/.htpasswd admin; then
        echo "✅ Basic Auth erfolgreich erstellt!"
        auth_success=true
    else
        echo "❌ Fehler beim Erstellen der Basic Auth Datei!"
        retry_count=$((retry_count + 1))
    fi
    
    # Passwort-Variablen löschen
    unset password1
    unset password2
done

if [ "$auth_success" = false ]; then
    echo ""
    echo "❌ Basic Auth konnte nach $max_retries Versuchen nicht erstellt werden."
    echo "💡 Alternative: Erstelle die Datei manuell nach dem Setup:"
    echo "   htpasswd -c ./nginx-config/.htpasswd admin"
    echo ""
    echo "Soll das Setup trotzdem fortgesetzt werden? (j/n)"
    read -r continue_setup
    
    if [[ ! $continue_setup =~ ^[Jj]$ ]]; then
        echo "Setup abgebrochen."
        exit 1
    fi
    
    # Erstelle eine temporäre .htpasswd mit Standard-Passwort
    echo "⚠️ Erstelle temporäre Basic Auth mit Passwort 'changeme123'"
    echo 'changeme123' | htpasswd -c -i ./nginx-config/custom/.htpasswd admin
    echo "🔧 WICHTIG: Ändere das Passwort nach dem Setup mit:"
    echo "   htpasswd ./nginx-config/custom/.htpasswd admin"
fi

# Erstelle selbstsignierte Zertifikate für interne Domain
echo ""
echo "🔑 Erstelle selbstsignierte SSL-Zertifikate für chef.fritz.box..."

# Erstelle SSL Konfigurationsdatei
cat > /tmp/ssl.conf << EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = DE
ST = Germany
L = Home
O = HomeNetwork
OU = IT Department
CN = chef.fritz.box
emailAddress = admin@chef.fritz.box

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = chef.fritz.box
DNS.2 = chef
DNS.3 = localhost
IP.1 = 192.168.1.100
IP.2 = 127.0.0.1
EOF

# Erstelle Zertifikate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./nginx-config/ssl/chef.fritz.box.key \
    -out ./nginx-config/ssl/chef.fritz.box.crt \
    -config /tmp/ssl.conf

# Aufräumen
rm /tmp/ssl.conf

# Setze Berechtigungen für SSL-Dateien
chmod 600 ./nginx-config/ssl/chef.fritz.box.key
chmod 644 ./nginx-config/ssl/chef.fritz.box.crt

# Erstelle .env Datei aus Template
echo "⚙️ Erstelle .env Konfigurationsdatei..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ .env Datei erstellt. Bitte anpassen falls nötig."
else
    echo "ℹ️ .env Datei existiert bereits."
fi

echo ""
echo "=================================================================="
echo "=== SYSTEM KONFIGURATION ==="
echo "=================================================================="

# Hostname setzen (falls gewünscht)
current_hostname=$(hostname)
echo "Aktueller Hostname: $current_hostname"
echo "Soll der Hostname zu 'chef' geändert werden? (j/n)"
read -r change_hostname

if [[ $change_hostname =~ ^[Jj]$ ]]; then
    echo "🏠 Setze Hostname auf 'chef'..."
    sudo hostnamectl set-hostname chef
    echo "✅ Hostname geändert. Neustart empfohlen."
fi

# Statische IP empfehlen
echo ""
echo "💡 EMPFEHLUNG: Konfiguriere eine statische IP-Adresse"
echo "   Bearbeite /etc/dhcpcd.conf für eine feste IP"
echo "   Beispiel für 192.168.1.100:"
echo "   interface eth0"
echo "   static ip_address=192.168.1.100/24"
echo "   static routers=192.168.1.1"
echo "   static domain_name_servers=192.168.1.1 8.8.8.8"

echo ""
echo "=================================================================="
echo "=== INSTALLATION ABGESCHLOSSEN! ==="
echo "=================================================================="
echo ""
echo "🎉 Docker und Nginx Proxy Manager Setup ist bereit!"
echo ""
echo "⚠️  WICHTIG: Neustart erforderlich für Docker Gruppenmitgliedschaft:"
echo "    sudo reboot"
echo ""
echo "📋 Nach dem Neustart:"
echo "    1. cd $(pwd)"
echo "    2. docker compose up -d"
echo "    3. Warte 30-60 Sekunden"
echo "    4. Öffne https://chef.fritz.box oder https://myhomeassi23.ddns.net"
echo "    5. Login: admin@example.com / changeme"
echo "    6. SOFORT Passwort ändern!"
echo ""
echo "🌐 Netzwerk Setup:"
echo "    - Router: Port 80 und 443 an diesen Pi weiterleiten"
echo "    - DNS: myhomeassi23.ddns.net auf öffentliche IP zeigen lassen"
echo ""
echo "🔧 Konfiguration:"
echo "    - Basic Auth User: admin"
echo "    - Config Dateien: ./nginx-config/"
echo "    - Logs: docker compose logs -f"
echo ""
echo "📚 Vollständige Dokumentation in README.md"
echo ""

# Neustart anbieten
echo "Möchtest du jetzt neu starten? (j/n)"
read -r restart_now

if [[ $restart_now =~ ^[Jj]$ ]]; then
    echo "🔄 System wird neu gestartet..."
    sudo reboot
else
    echo "ℹ️ Bitte manuell neu starten mit: sudo reboot"
fi
