# 🚀 INSTALLATION - Nginx Proxy Manager für Raspberry Pi 5

## 📋 Komplette Neuinstallation Schritt-für-Schritt

Diese Anleitung führt dich durch die komplette Installation eines Nginx Proxy Manager auf einem frischen Raspberry Pi 5 mit allen Bugfixes und Sicherheitsfeatures.

## 🎯 Endergebnis
- **Externe Domain:** https://myhomeassi23.ddns.net (Let's Encrypt SSL)
- **Interne Domain:** https://chef.fritz.box (Selbstsigniertes SSL)
- **Sicherheit:** Basic Auth + SSL überall
- **Auto-Start:** Startet automatisch nach Pi Neuboot

---

## 📱 **SCHRITT 1: Raspberry Pi OS Installation**

### 1.1 SD-Karte vorbereiten
1. **Raspberry Pi Imager** herunterladen: https://rpi.org/imager
2. **SD-Karte** (min. 32GB) einlegen
3. **Raspberry Pi OS Lite (64-bit)** auswählen
4. **⚙️ Erweiterte Optionen** (Zahnrad-Symbol):
   - ✅ **SSH aktivieren**
   - 👤 **Benutzer:** `pi` / **Passwort:** `[dein-sicheres-passwort]`
   - 🌐 **WLAN konfigurieren:** SSID + Passwort eingeben
   - 🏠 **Hostname:** `chef`
   - 🌍 **Zeitzone:** `Europe/Berlin`
5. **Schreiben** und **SD-Karte in Pi einlegen**

### 1.2 Erste Anmeldung
```bash
# Pi IP-Adresse im Router finden (meist 192.168.178.1)
# SSH Verbindung herstellen
ssh pi@[PI-IP-ADRESSE]

# System vollständig aktualisieren
sudo apt update && sudo apt upgrade -y

# Neustart nach Updates
sudo reboot
```

---

## 🐳 **SCHRITT 2: Docker Installation**

```bash
# Erneut per SSH anmelden
ssh pi@[PI-IP-ADRESSE]

# Docker Installation Script herunterladen und ausführen
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Pi User zu Docker Gruppe hinzufügen
sudo usermod -aG docker pi

# Aufräumen
rm get-docker.sh

# WICHTIG: Neuanmeldung für Gruppenrechte
exit
ssh pi@[PI-IP-ADRESSE]

# Docker Installation testen
docker --version
docker compose version
```

**Erwartete Ausgabe:**
```
Docker version 24.x.x
Docker Compose version v2.x.x
```

---

## 📁 **SCHRITT 3: Projekt Setup**

```bash
# Repository mit allen Bugfixes klonen
cd ~
git clone https://github.com/OliverRebock/nginx-proxy-manager-pi5.git
cd nginx-proxy-manager-pi5

# Verzeichnisstruktur prüfen
ls -la
```

**Du solltest sehen:**
```
drwxr-xr-x  2 pi pi 4096 config/
drwxr-xr-x  2 pi pi 4096 data/
-rw-r--r--  1 pi pi 1234 docker-compose.yml
drwxr-xr-x  2 pi pi 4096 docs/
drwxr-xr-x  2 pi pi 4096 scripts/
drwxr-xr-x  2 pi pi 4096 ssl-certs/
```

---

## 🔧 **SCHRITT 4: Automatische Installation**

### Option A: Komplette Automatik (EMPFOHLEN)
```bash
# Das komplette Setup-Script ausführen
chmod +x scripts/pi-full-setup.sh
./scripts/pi-full-setup.sh
```

**Das Script macht automatisch:**
- ✅ Docker Container Start
- ✅ Basic Auth Konfiguration (mit Retry-Logic)
- ✅ SSL Zertifikat Generation (browser-kompatibel)
- ✅ Alle Verzeichnisse und Berechtigungen

### Option B: Manueller Schritt-für-Schritt (falls gewünscht)

#### 4.1 Docker Container starten
```bash
docker compose up -d
```

#### 4.2 Container Status prüfen
```bash
# Status prüfen (sollte "healthy" zeigen)
docker compose ps

# 60 Sekunden warten bis NPM vollständig geladen
sleep 60

# Erreichbarkeit testen
curl -I http://localhost:81
```

#### 4.3 Basic Auth einrichten
```bash
chmod +x scripts/setup-basic-auth.sh
./scripts/setup-basic-auth.sh
```

#### 4.4 SSL Zertifikat erstellen
```bash
chmod +x scripts/generate-ssl-cert.sh
./scripts/generate-ssl-cert.sh
```

---

## 🌐 **SCHRITT 5: Router Konfiguration**

### 5.1 Port Forwarding einrichten
Im Router (meist http://192.168.178.1):

**Portfreigaben:**
- **Port 80** → Pi IP:80 (für Let's Encrypt Validierung)
- **Port 443** → Pi IP:443 (für HTTPS Traffic)
- **Port 81** → ❌ NICHT freigeben (nur intern)

### 5.2 DNS Konfiguration
- **DynDNS:** myhomeassi23.ddns.net → Öffentliche IP
- **Lokaler DNS:** chef.fritz.box → Pi IP (im Router oder Hosts-Datei)

---

## 🔐 **SCHRITT 6: NPM Konfiguration**

### 6.1 Erste Anmeldung
```bash
# Browser öffnen
http://[PI-IP]:81
```

**Standard Login:**
- **Email:** `admin@example.com`
- **Passwort:** `changeme`
- **⚠️ SOFORT Passwort ändern!**

### 6.2 Let's Encrypt für externe Domain

**SSL Certificates → Add SSL Certificate → Let's Encrypt**
- **Domain Names:** `myhomeassi23.ddns.net`
- **Email:** `deine-email@domain.com`
- ✅ **Use DNS Challenge** (empfohlen)
- **DNS Provider:** je nach Anbieter konfigurieren

### 6.3 Custom SSL für interne Domain

**SSL Certificates → Add SSL Certificate → Custom**
- **Name:** `chef.fritz.box`
- **Certificate Key:** [Inhalt aus Script kopieren - siehe Terminal]
- **Certificate:** [Inhalt aus Script kopieren - siehe Terminal]

### 6.4 Proxy Host für externe Domain

**Hosts → Proxy Hosts → Add Proxy Host**

**Details Tab:**
- **Domain Names:** `myhomeassi23.ddns.net`
- **Scheme:** `http`
- **Forward Hostname/IP:** `127.0.0.1`
- **Forward Port:** `81`
- ✅ **Cache Assets**
- ✅ **Block Common Exploits**
- ✅ **Websockets Support**

**SSL Tab:**
- **SSL Certificate:** `myhomeassi23.ddns.net`
- ✅ **Force SSL**
- ✅ **HTTP/2 Support**
- ✅ **HSTS Enabled**

**Advanced Tab:**
```nginx
# Security Headers
add_header X-Frame-Options DENY always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### 6.5 Proxy Host für interne Domain

**Hosts → Proxy Hosts → Add Proxy Host**

**Details Tab:**
- **Domain Names:** `chef.fritz.box chef`
- **Scheme:** `http`
- **Forward Hostname/IP:** `127.0.0.1`
- **Forward Port:** `81`
- ✅ **Cache Assets**
- ✅ **Block Common Exploits**
- ✅ **Websockets Support**

**SSL Tab:**
- **SSL Certificate:** `chef.fritz.box`
- ✅ **Force SSL**
- ✅ **HTTP/2 Support**

**Advanced Tab:**
```nginx
# Security Headers
add_header X-Frame-Options DENY always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

---

## 🔒 **SCHRITT 7: Sicherheit & Access Lists (Optional)**

### 7.1 Access Lists erstellen
**Access Lists → Add Access List**
- **Name:** `Admin Only`
- ✅ **Satisfy Any**
- **Authorization → Add:**
  - **Type:** `Username/Password`
  - **Username:** `admin`
  - **Password:** `[dein-sicheres-passwort]`

### 7.2 Access Lists zu Proxy Hosts zuweisen
Bei beiden Proxy Hosts unter **Access List** die erstellte Liste auswählen.

---

## 🧪 **SCHRITT 8: Funktionstest**

### 8.1 Externe Domain testen
```bash
# Browser öffnen
https://myhomeassi23.ddns.net
```

**Erwartetes Ergebnis:**
- ✅ Grünes SSL-Schloss (Let's Encrypt)
- ✅ NPM Admin Interface lädt
- ✅ Keine Browser-Warnungen

### 8.2 Interne Domain testen
```bash
# Browser öffnen
https://chef.fritz.box
```

**Erwartetes Ergebnis:**
- ⚠️ Browser Warnung (normal bei selbstsigniert)
- ✅ "Erweitert" → "Trotzdem fortfahren"
- ✅ NPM Admin Interface lädt
- ❌ KEINE `ERR_SSL_KEY_USAGE_INCOMPATIBLE` Fehlermeldung

---

## 🛡️ **SCHRITT 9: Backup & Wartung**

### 9.1 Backup Script erstellen
```bash
cat > ~/backup-npm.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
cd ~/nginx-proxy-manager-pi5
tar -czf ~/npm-backup-$DATE.tar.gz data/
echo "✅ Backup erstellt: ~/npm-backup-$DATE.tar.gz"
ls -lh ~/npm-backup-*.tar.gz
EOF

chmod +x ~/backup-npm.sh

# Backup testen
./backup-npm.sh
```

### 9.2 Auto-Start Service einrichten
```bash
sudo tee /etc/systemd/system/nginx-proxy-manager.service > /dev/null << 'EOF'
[Unit]
Description=Nginx Proxy Manager
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/pi/nginx-proxy-manager-pi5
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=pi

[Install]
WantedBy=multi-user.target
EOF

# Service aktivieren und starten
sudo systemctl enable nginx-proxy-manager.service
sudo systemctl start nginx-proxy-manager.service

# Status prüfen
sudo systemctl status nginx-proxy-manager.service
```

### 9.3 Neustart testen
```bash
# Pi neustarten
sudo reboot

# Nach Neustart: SSH und Container Status prüfen
ssh pi@[PI-IP]
cd ~/nginx-proxy-manager-pi5
docker compose ps
```

---

## ✅ **INSTALLATION ABGESCHLOSSEN!**

### 🎯 **Was du jetzt hast:**

1. **Externe Domain:** https://myhomeassi23.ddns.net
   - ✅ Let's Encrypt SSL (automatische Erneuerung)
   - ✅ Öffentlich erreichbar
   - ✅ Sichere Verbindung

2. **Interne Domain:** https://chef.fritz.box
   - ✅ Selbstsigniertes SSL (browser-kompatibel)
   - ✅ Lokaler Zugriff
   - ✅ Keine SSL-Fehler mehr

3. **Sicherheitsfeatures:**
   - ✅ Basic Authentication
   - ✅ Security Headers
   - ✅ HTTPS-only
   - ✅ Rate Limiting

4. **Betrieb:**
   - ✅ Auto-Start nach Neuboot
   - ✅ Backup-System
   - ✅ Docker Health Checks
   - ✅ Vollständige Dokumentation

### 🔧 **Wartung:**

```bash
# Container Updates
cd ~/nginx-proxy-manager-pi5
docker compose pull
docker compose up -d

# Backup erstellen
~/backup-npm.sh

# Logs anzeigen
docker compose logs -f

# Container neustarten
docker compose restart
```

### 📚 **Weitere Dokumentation:**

- `docs/npm-configuration.md` - Detaillierte NPM Konfiguration
- `docs/ssl-key-usage-fix.md` - SSL Troubleshooting
- `docs/pi-installation.md` - Pi Setup Details

---

## 🎉 **HERZLICHEN GLÜCKWUNSCH!**

Dein Nginx Proxy Manager ist jetzt vollständig installiert und konfiguriert mit allen Bugfixes und Sicherheitsfeatures! 🚀

**Bei Fragen oder Problemen:** Prüfe die Dokumentation im `docs/` Verzeichnis oder erstelle ein Issue im GitHub Repository.
