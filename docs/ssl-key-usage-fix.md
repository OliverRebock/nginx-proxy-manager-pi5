# SSL Certificate Key Usage Fix für chef.fritz.box

## Problem
Der aktuelle SSL Certificate zeigt den Fehler `ERR_SSL_KEY_USAGE_INCOMPATIBLE` weil die X509v3 Key Usage Extensions nicht korrekt sind.

**Aktuell:**
```
X509v3 Key Usage: Key Encipherment, Data Encipherment
```

**Benötigt:**
```
X509v3 Key Usage: Digital Signature, Key Encipherment
```

## Lösung: Neues Zertifikat im NPM Container generieren

### Schritt 1: SSL Configuration erstellen
```bash
docker compose exec nginx-proxy-manager sh -c "
cat > /tmp/ssl-chef-fixed.conf << 'EOF'
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
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = chef.fritz.box
DNS.2 = chef
DNS.3 = localhost
IP.1 = 127.0.0.1
EOF"
```

### Schritt 2: Neues Zertifikat generieren
```bash
docker compose exec nginx-proxy-manager openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/chef-fixed.key \
    -out /tmp/chef-fixed.crt \
    -extensions v3_req \
    -config /tmp/ssl-chef-fixed.conf
```

### Schritt 3: Zertifikat Inhalte anzeigen
```bash
echo "=== PRIVATE KEY ==="
docker compose exec nginx-proxy-manager cat /tmp/chef-fixed.key

echo "=== CERTIFICATE ==="
docker compose exec nginx-proxy-manager cat /tmp/chef-fixed.crt
```

### Schritt 4: Zertifikat Extensions prüfen
```bash
docker compose exec nginx-proxy-manager openssl x509 -in /tmp/chef-fixed.crt -text -noout | grep -A 10 "X509v3 extensions"
```

**Erwartetes Ergebnis:**
```
X509v3 extensions:
    X509v3 Basic Constraints:
        CA:FALSE
    X509v3 Key Usage:
        Digital Signature, Key Encipherment
    X509v3 Extended Key Usage:
        TLS Web Server Authentication
    X509v3 Subject Alternative Name:
        DNS:chef.fritz.box, DNS:chef, DNS:localhost, IP Address:127.0.0.1
```

### Schritt 5: Neues Custom SSL Certificate in NPM erstellen

1. **NPM Admin Interface öffnen:** http://PI-IP:81
2. **SSL Certificates → Add SSL Certificate → Custom**
3. **Name:** `chef.fritz.box-fixed`
4. **Certificate Key:** [Inhalt von chef-fixed.key komplett einfügen]
5. **Certificate:** [Inhalt von chef-fixed.crt komplett einfügen]
6. **Save**

### Schritt 6: Proxy Host aktualisieren

1. **Hosts → Proxy Hosts → chef.fritz.box (bearbeiten)**
2. **SSL Tab**
3. **SSL Certificate:** `chef.fritz.box-fixed` (das neue Zertifikat auswählen)
4. **Save**

### Schritt 7: Testen
```bash
# Browser Test
https://chef.fritz.box
```

**Erwartetes Ergebnis:**
- Browser Warnung wegen selbstsigniertem Zertifikat (normal)
- KEINE ERR_SSL_KEY_USAGE_INCOMPATIBLE Fehlermeldung mehr
- Nach "Erweitert → Trotzdem fortfahren" → NPM Interface lädt

## Alternative: Auf Raspberry Pi direkt

Falls Docker auf Windows nicht verfügbar ist, diese Befehle direkt auf dem Pi ausführen:

```bash
# SSH zum Pi
ssh pi@PI-IP-ADRESSE

cd ~/nginx-proxy-manager-pi5

# Verbesserte SSL Config
cat > ssl-chef-fixed.conf << 'EOF'
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

# Neues Zertifikat erstellen
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl-certs/chef-fixed.key \
    -out ssl-certs/chef-fixed.crt \
    -extensions v3_req \
    -config ssl-chef-fixed.conf

# Zertifikat prüfen
openssl x509 -in ssl-certs/chef-fixed.crt -text -noout | grep -A 10 "X509v3 extensions"

# Inhalte anzeigen für NPM
echo "=== PRIVATE KEY ==="
cat ssl-certs/chef-fixed.key
echo "=== CERTIFICATE ==="
cat ssl-certs/chef-fixed.crt
```

## Wichtige Hinweise

1. **Key Usage ist kritisch:** Moderne Browser verlangen `digitalSignature` für HTTPS
2. **Backup:** Altes Zertifikat erst löschen nach erfolgreichem Test
3. **Browser Cache:** Nach Zertifikat-Wechsel Browser Cache leeren
4. **Gültigkeit:** Neues Zertifikat ist 365 Tage gültig
