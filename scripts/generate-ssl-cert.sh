#!/bin/bash

# SSL Zertifikat Generator für interne Domains
# Erstellt selbstsignierte Zertifikate für chef.fritz.box

echo "🔐 SSL Zertifikat Generator für interne Domains"
echo "=============================================="

# Erstelle SSL Verzeichnis
mkdir -p ./ssl-certs

# Zertifikat für chef.fritz.box erstellen
echo "📋 Erstelle selbstsigniertes Zertifikat für chef.fritz.box..."

# Erweiterte SSL Konfiguration für bessere Browser-Kompatibilität
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
emailAddress = admin@chef.fritz.box

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = chef.fritz.box
DNS.2 = chef
DNS.3 = localhost
IP.1 = 127.0.0.1
IP.2 = $(hostname -I | awk '{print $1}')
EOF

# Erstelle Zertifikat mit korrekten Extensions für Server-Authentifizierung
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./ssl-certs/chef.fritz.box.key \
    -out ./ssl-certs/chef.fritz.box.crt \
    -extensions v3_req \
    -config /tmp/ssl-chef.conf

# Aufräumen
rm /tmp/ssl-chef.conf

# Berechtigungen setzen
chmod 600 ./ssl-certs/chef.fritz.box.key
chmod 644 ./ssl-certs/chef.fritz.box.crt

echo ""
echo "✅ SSL Zertifikat erfolgreich erstellt!"
echo ""
echo "📁 Dateien:"
echo "   Private Key: ./ssl-certs/chef.fritz.box.key"
echo "   Certificate: ./ssl-certs/chef.fritz.box.crt"
echo ""
echo "🔧 Für NPM Custom SSL Certificate:"
echo ""

echo "=== PRIVATE KEY (komplett kopieren) ==="
cat ./ssl-certs/chef.fritz.box.key
echo ""
echo "=== CERTIFICATE (komplett kopieren) ==="
cat ./ssl-certs/chef.fritz.box.crt
echo ""

echo "💡 Anleitung:"
echo "1. NPM → SSL Certificates → Add SSL Certificate → Custom"
echo "2. Name: chef.fritz.box"
echo "3. Certificate Key: [Private Key von oben kopieren]"
echo "4. Certificate: [Certificate von oben kopieren]"
echo "5. Save"
echo ""
echo "⚠️  Browser Warnung bei selbstsignierten Zertifikaten ist normal!"
echo "   Einfach 'Erweitert' → 'Trotzdem fortfahren' klicken."
