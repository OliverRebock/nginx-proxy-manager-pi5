# Nginx Proxy Manager für Raspberry Pi 5

Ein sicheres Docker-Setup für Nginx Proxy Manager mit HTTPS-only Zugriff, externer und interner Domain-Unterstützung.

## 🎯 Projektziel

- **Externe Domain**: myhomeassi23.ddns.net (HTTPS mit Let's Encrypt)
- **Interne Domain**: chef.fritz.box (HTTPS mit selbstsignierten Zertifikaten)
- **Hostname**: chef
- **Sicherheit**: Nur HTTPS, Basic Auth, Security Headers
- **Konfiguration**: Gemountete Config-Dateien für manuelle Bearbeitung

## 📁 Projektstruktur

```
nginx-proxy-manager/
├── docker-compose.yml      # Docker Container Konfiguration
├── nginx-config/           # Nginx Konfigurationsdateien (gemountet)
│   ├── default.conf        # Haupt-Nginx Konfiguration
│   ├── .htpasswd          # Basic Auth Datei
│   └── ssl/               # SSL Zertifikate für interne Domain
├── config/                # Nginx Proxy Manager Konfiguration
│   ├── nginx/             # NPM interne Nginx Konfiguration
│   └── letsencrypt/       # Let's Encrypt Zertifikate
├── data/                  # Datenbank und Logs
├── docs/                  # Zusätzliche Dokumentation
│   └── pi-installation.md # Komplette Pi Setup Anleitung
└── scripts/               # Setup Scripts
    ├── pi-full-setup.sh   # Vollständige Pi Installation (für frische Pi)
    ├── start-nginx.sh     # Container Start Script
    ├── setup.sh           # Basis Setup (Docker bereits installiert)
    └── setup.bat          # Windows Vorbereitungsscript
```

## 🚀 Installation auf Raspberry Pi 5

### Variante A: Frisch installierter Raspberry Pi 5

**Für einen komplett neuen Pi (empfohlen):**

1. **Projekt auf Raspberry Pi kopieren**
   ```bash
   # Via USB, SCP oder Git
   git clone <repository> nginx-proxy-manager
   cd nginx-proxy-manager
   ```

2. **Vollständiges Setup ausführen**
   ```bash
   chmod +x scripts/pi-full-setup.sh
   ./scripts/pi-full-setup.sh
   ```
   
   Das Script installiert:
   - ✅ Alle Systemupdates
   - ✅ Docker & Docker Compose
   - ✅ Grundlegende Tools (curl, git, htpasswd, etc.)
   - ✅ Basic Auth Konfiguration
   - ✅ SSL-Zertifikate für interne Domain
   - ✅ Benutzerberechtigungen für Docker

3. **Neustart durchführen**
   ```bash
   sudo reboot
   ```

4. **Nach Neustart: Container starten**
   ```bash
   cd nginx-proxy-manager
   chmod +x scripts/start-nginx.sh
   ./scripts/start-nginx.sh
   ```

### Variante B: Pi mit bereits installiertem Docker

**Falls Docker bereits installiert ist:**

```bash
# Nur Nginx Proxy Manager Setup
chmod +x scripts/setup.sh
./scripts/setup.sh

# Container starten
docker compose up -d
```

## 🔐 Erstkonfiguration

### Zugriff auf Admin Interface

- **Extern**: https://myhomeassi23.ddns.net
- **Intern**: https://chef.fritz.box
- **Standard Login**: admin@example.com / changeme

### Wichtige erste Schritte

1. **Passwort ändern** (SOFORT!)
2. **Let's Encrypt für externe Domain konfigurieren**
   - Domain: myhomeassi23.ddns.net
   - Email-Adresse eingeben
   - "Force SSL" aktivieren
   - "HTTP/2 Support" aktivieren

## 🛡️ Sicherheitsfeatures

### Aktivierte Sicherheitsmaßnahmen

- ✅ HTTPS-only (HTTP → HTTPS Redirect)
- ✅ Basic Authentication vor NPM Interface
- ✅ Security Headers (HSTS, X-Frame-Options, etc.)
- ✅ TLS 1.2/1.3 only
- ✅ Sichere Cipher Suites
- ✅ Gesonderte Docker-Netzwerk-Isolation

### SSL/TLS Konfiguration

- **Extern (myhomeassi23.ddns.net)**: Let's Encrypt Zertifikate
- **Intern (chef.fritz.box)**: Selbstsignierte Zertifikate
- **Protokolle**: TLS 1.2, TLS 1.3
- **Perfect Forward Secrecy**: Aktiviert

## 🔧 Konfiguration anpassen

### Nginx Konfiguration bearbeiten

```bash
# Direkt auf dem Pi
nano nginx-config/default.conf

# Nach Änderungen Container neu starten
docker-compose restart nginx-proxy-manager
```

### Basic Auth Passwort ändern

```bash
# Neues Passwort setzen
htpasswd nginx-config/.htpasswd admin

# Container neu starten
docker-compose restart nginx-proxy-manager
```

### Zusätzliche Domains hinzufügen

Bearbeite `nginx-config/default.conf` und füge weitere `server` Blöcke hinzu.

## 📊 Monitoring & Wartung

### Container Status prüfen

```bash
# Status aller Container
docker-compose ps

# Logs anzeigen
docker-compose logs -f nginx-proxy-manager

# Ressourcenverbrauch
docker stats nginx-proxy-manager
```

### Backups

```bash
# Konfiguration und Daten sichern
tar -czf npm-backup-$(date +%Y%m%d).tar.gz config/ data/ nginx-config/
```

### Updates

```bash
# Images aktualisieren
docker-compose pull
docker-compose up -d
```

## 🌐 Netzwerk-Konfiguration

### Router/Firewall Einstellungen

- **Port 80** → Raspberry Pi (für Let's Encrypt Challenge)
- **Port 443** → Raspberry Pi (HTTPS Traffic)
- **Port 81** → NICHT freigeben (nur intern)

### DNS Konfiguration

- **Externe Domain**: myhomeassi23.ddns.net → Öffentliche IP
- **Interne Domain**: chef.fritz.box → 192.168.x.x (Pi IP)

## ⚠️ Troubleshooting

### Häufige Probleme

1. **Container startet nicht**
   ```bash
   docker-compose logs nginx-proxy-manager
   ```

2. **SSL-Fehler bei interner Domain**
   - Browser Warnung akzeptieren (selbstsignierte Zertifikate)
   - Oder: Zertifikat in Browser importieren

3. **Let's Encrypt schlägt fehl**
   - DNS-Auflösung prüfen
   - Port 80 Erreichbarkeit testen
   - Logs prüfen: `docker-compose logs`

4. **Basic Auth funktioniert nicht**
   - .htpasswd Datei prüfen
   - Berechtigungen kontrollieren
   - Container neu starten

## 📝 Logs & Debugging

```bash
# Alle Logs
docker-compose logs

# Nur Fehler
docker-compose logs | grep -i error

# Live-Logs
docker-compose logs -f

# Container Shell
docker exec -it nginx-proxy-manager sh
```

## 🎯 Nächste Schritte

Nach erfolgreicher Installation:

1. **Proxy Hosts einrichten** über NPM Interface
2. **SSL-Zertifikate** für alle Domains konfigurieren
3. **Access Lists** für zusätzliche Sicherheit
4. **Custom Locations** für spezielle Anforderungen
5. **Backup-Strategie** implementieren

---

**Entwickelt für**: Raspberry Pi 5  
**Getestet mit**: Docker 24.x, NPM latest  
**Sicherheitslevel**: Hoch (HTTPS-only, Authentication, Security Headers)
