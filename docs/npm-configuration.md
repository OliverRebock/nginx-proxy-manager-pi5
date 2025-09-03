# NPM Konfiguration für myhomeassi23.ddns.net und chef.fritz.box

## Nach der Installation diese Schritte in NPM ausführen:

### 1. Erste Anmeldung
- URL: http://IP-DES-PI:81
- Email: admin@example.com
- Passwort: changeme
- **SOFORT Passwort ändern!**

### 2. SSL Zertifikat für externe Domain erstellen

⚠️ **NUR für externe Domain**: `myhomeassi23.ddns.net`

**SSL Certificates → Add SSL Certificate → Let's Encrypt**
- Domain Names: `myhomeassi23.ddns.net`
- Email: `deine-email@domain.com`
- ✅ Use DNS Challenge (empfohlen für bessere Sicherheit)
- DNS Provider: je nach Anbieter konfigurieren

**WICHTIG**: Let's Encrypt funktioniert NUR für öffentlich erreichbare Domains!

### 3. Proxy Host für externe Domain erstellen

**Hosts → Proxy Hosts → Add Proxy Host**

**Details Tab:**
- Domain Names: `myhomeassi23.ddns.net`
- Scheme: `http`
- Forward Hostname/IP: `127.0.0.1`
- Forward Port: `81`
- ✅ Cache Assets
- ✅ Block Common Exploits
- ✅ Websockets Support

**SSL Tab:**
- SSL Certificate: `myhomeassi23.ddns.net` (das eben erstellte)
- ✅ Force SSL
- ✅ HTTP/2 Support
- ✅ HSTS Enabled
- HSTS Subdomains: ✅

**Advanced Tab:**
```nginx
# Security Headers
add_header X-Frame-Options DENY always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Rate Limiting für Admin Bereich
location /admin {
    limit_req zone=login burst=5 nodelay;
}

# Basic Auth für zusätzliche Sicherheit (optional)
# auth_basic "Admin Area";
# auth_basic_user_file /data/nginx/custom/.htpasswd;
```

### 4. Selbstsigniertes Zertifikat für interne Domain

⚠️ **WICHTIG**: Für `chef.fritz.box` KEIN Let's Encrypt verwenden! 
Interne Domains brauchen Custom Zertifikate.

**Schritt 4a: Zertifikat erstellen (auf dem Pi)**
```bash
# Verwende das verbesserte Script für browser-kompatible Zertifikate
cd ~/nginx-proxy-manager-pi5
chmod +x scripts/generate-ssl-cert.sh
./scripts/generate-ssl-cert.sh
```

**ODER manuell mit korrekten Extensions:**
```bash
# SSL Config Datei erstellen
cat > /tmp/ssl-chef.conf << EOF
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

[v3_req]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = chef.fritz.box
DNS.2 = chef
DNS.3 = localhost
IP.1 = 127.0.0.1
EOF

# Zertifikat mit korrekten Server-Extensions erstellen
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl-certs/chef.fritz.box.key \
    -out ssl-certs/chef.fritz.box.crt \
    -extensions v3_req \
    -config /tmp/ssl-chef.conf

# Zertifikat-Inhalte anzeigen
echo "=== PRIVATE KEY ==="
cat ssl-certs/chef.fritz.box.key
echo "=== CERTIFICATE ==="
cat ssl-certs/chef.fritz.box.crt
```

**Schritt 4b: Custom Zertifikat in NPM hinzufügen**

**SSL Certificates → Add SSL Certificate → Custom**
- Name: `chef.fritz.box`
- Certificate Key: [Inhalt von chef.fritz.box.key komplett kopieren]
- Certificate: [Inhalt von chef.fritz.box.crt komplett kopieren]

### 5. Proxy Host für interne Domain erstellen

**Hosts → Proxy Hosts → Add Proxy Host**

**Details Tab:**
- Domain Names: `chef.fritz.box chef`
- Scheme: `http`
- Forward Hostname/IP: `127.0.0.1`
- Forward Port: `81`
- ✅ Cache Assets
- ✅ Block Common Exploits
- ✅ Websockets Support

**SSL Tab:**
- SSL Certificate: `chef.fritz.box` (das eben erstellte)
- ✅ Force SSL
- ✅ HTTP/2 Support

**Advanced Tab:**
```nginx
# Security Headers (gleich wie externe Domain)
add_header X-Frame-Options DENY always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Warnung für selbstsigniertes Zertifikat unterdrücken (optional)
add_header X-Internal-Network "true" always;
```

### 6. Access Lists für zusätzliche Sicherheit (Optional)

**Access Lists → Add Access List**
- Name: `Admin Only`
- ✅ Satisfy Any
- Authorization → Add:
  - Type: `Username/Password`
  - Username: `admin`
  - Password: [dein sicheres Passwort]

Dann bei beiden Proxy Hosts unter "Access List" die erstellte Liste zuweisen.

### 7. Testen der Konfiguration

1. **Extern**: https://myhomeassi23.ddns.net
   - Sollte grünes SSL Schloss zeigen
   - NPM Admin Interface laden

2. **Intern**: https://chef.fritz.box
   - Browser Warnung wegen selbstsigniertem Zertifikat (normal)
   - Warnung akzeptieren
   - NPM Admin Interface laden

### 8. Router Konfiguration prüfen

**Port Forwarding:**
- Port 80 → Pi IP:80 (für Let's Encrypt Challenge)
- Port 443 → Pi IP:443 (für HTTPS Traffic)
- Port 81 → NICHT weiterleiten (nur intern)

**DNS:**
- myhomeassi23.ddns.net → Öffentliche IP
- chef.fritz.box → Pi IP (Router DNS oder Hosts-Datei)

---

## Wichtige Hinweise:

1. **Backup erstellen**: NPM Daten regelmäßig sichern (`./data` Verzeichnis)
2. **Updates**: Container regelmäßig aktualisieren: `docker compose pull && docker compose up -d`
3. **Logs überwachen**: `docker compose logs -f nginx-proxy-manager`
4. **Sicherheit**: Access Lists und starke Passwörter verwenden
