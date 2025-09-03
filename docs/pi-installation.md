# Raspberry Pi 5 Erstinstallation - Komplette Anleitung

## 🎯 Vorbereitung des Raspberry Pi 5

### Was du brauchst:
- Raspberry Pi 5 mit mindestens 4GB RAM
- MicroSD-Karte (mindestens 32GB, Class 10)
- Stable Internetverbindung
- SSH-Zugang oder Monitor + Tastatur

## 📀 Raspberry Pi OS Installation

### 1. Raspberry Pi Imager verwenden
```bash
# Download von: https://www.raspberrypi.com/software/
# Verwende Raspberry Pi OS Lite (64-bit) für Server
```

### 2. Erweiterte Optionen konfigurieren
- ✅ SSH aktivieren
- ✅ Benutzername/Passwort setzen
- ✅ WLAN konfigurieren (falls nötig)
- ✅ Lokalisierung setzen (Deutschland, Europe/Berlin)

### 3. Erste Verbindung
```bash
# SSH Verbindung
ssh pi@192.168.1.XXX

# Oder direkt am Pi anmelden
```

## 🔧 System Grundkonfiguration

### Automatische Konfiguration mit unserem Script
```bash
# Projekt herunterladen
git clone <repository> nginx-proxy-manager
cd nginx-proxy-manager

# Vollständiges Setup ausführen
chmod +x scripts/pi-full-setup.sh
./scripts/pi-full-setup.sh
```

**Das Script macht alles automatisch:**
- ✅ System Updates
- ✅ Docker Installation
- ✅ Benutzerberechtigungen
- ✅ Nginx Proxy Manager Setup
- ✅ SSL-Zertifikate
- ✅ Basic Authentication

### Nach dem Script:
1. **Neustart** (wird angeboten)
2. **Container starten** mit `./scripts/start-nginx.sh`
3. **Router konfigurieren** (Ports 80, 443)
4. **DNS einrichten** (myhomeassi23.ddns.net)

## 🌐 Netzwerk Konfiguration

### Router Setup
```bash
# Port Forwarding einrichten:
Port 80 (HTTP) → Pi IP:80
Port 443 (HTTPS) → Pi IP:443

# Port 81 NICHT weiterleiten (nur intern)
```

### Statische IP empfohlen
```bash
# /etc/dhcpcd.conf bearbeiten
sudo nano /etc/dhcpcd.conf

# Hinzufügen:
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

### DNS Konfiguration
- **Externe Domain**: myhomeassi23.ddns.net → Öffentliche IP
- **DDNS Service**: Einrichten bei DynDNS, No-IP, oder ähnlich
- **Interne Auflösung**: chef.fritz.box → Pi IP (Router/Pi-hole)

## 🛡️ Sicherheit nach Installation

### 1. Sofort ändern:
```bash
# NPM Standard Login ändern:
# Email: admin@example.com
# Passwort: changeme → DEIN_SICHERES_PASSWORT

# Pi Benutzer Passwort (falls Standard)
passwd
```

### 2. SSH absichern:
```bash
# SSH Konfiguration
sudo nano /etc/ssh/sshd_config

# Empfohlene Änderungen:
PermitRootLogin no
PasswordAuthentication yes  # oder mit Key-Auth: no
Port 2222  # Standard Port ändern
```

### 3. Firewall aktivieren:
```bash
# UFW installieren und konfigurieren
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp   # oder dein SSH Port
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## 📊 Nach der Installation prüfen

### Container Status
```bash
cd nginx-proxy-manager
docker compose ps
docker compose logs -f
```

### Zugriff testen
1. **Intern**: https://chef.fritz.box (SSL Warnung = OK)
2. **Extern**: https://myhomeassi23.ddns.net (nach DNS Setup)
3. **Fallback**: http://PI-IP:81

### Let's Encrypt einrichten
1. NPM Admin Interface öffnen
2. SSL Certificates → Add SSL Certificate
3. Let's Encrypt auswählen
4. Domain: myhomeassi23.ddns.net
5. Email eingeben
6. Save

## 🚨 Troubleshooting

### Pi startet nicht
- SD-Karte prüfen (flashen wiederholen)
- Stromversorgung prüfen (min. 5V/3A)
- HDMI für Fehlermeldungen anschließen

### Docker Berechtigung fehlt
```bash
# Nach Neustart prüfen
docker ps

# Falls Fehler:
sudo usermod -aG docker $USER
# Neu anmelden oder reboot
```

### Ports nicht erreichbar
```bash
# Firewall prüfen
sudo ufw status

# Ports testen
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

### DNS funktioniert nicht
```bash
# Externe Erreichbarkeit testen
nslookup myhomeassi23.ddns.net

# Router Port Forwarding prüfen
# DDNS Service Status prüfen
```

---

**Geschätzte Installationszeit**: 30-45 Minuten  
**Schwierigkeitsgrad**: Anfänger bis Fortgeschritten  
**Getestet mit**: Raspberry Pi OS Lite 64-bit, Pi 5 4GB/8GB
