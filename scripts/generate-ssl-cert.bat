@echo off
echo 🔐 SSL Zertifikat Generator für interne Domains
echo ==============================================

REM Erstelle SSL Verzeichnis
if not exist "ssl-certs" mkdir ssl-certs

echo 📋 Erstelle selbstsigniertes Zertifikat für chef.fritz.box...

REM Erstelle temporäre SSL Konfigurationsdatei
(
echo [req]
echo distinguished_name = req_distinguished_name
echo x509_extensions = v3_req
echo prompt = no
echo.
echo [req_distinguished_name]
echo C = DE
echo ST = Germany
echo L = Home
echo O = HomeNetwork
echo OU = IT Department
echo CN = chef.fritz.box
echo emailAddress = admin@chef.fritz.box
echo.
echo [v3_req]
echo basicConstraints = CA:FALSE
echo keyUsage = digitalSignature, keyEncipherment
echo extendedKeyUsage = serverAuth
echo subjectAltName = @alt_names
echo.
echo [alt_names]
echo DNS.1 = chef.fritz.box
echo DNS.2 = chef
echo DNS.3 = localhost
echo IP.1 = 127.0.0.1
) > ssl-chef.conf

REM Erstelle Zertifikat mit korrekten Extensions
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl-certs\chef.fritz.box.key -out ssl-certs\chef.fritz.box.crt -extensions v3_req -config ssl-chef.conf

REM Aufräumen
del ssl-chef.conf

echo.
echo ✅ SSL Zertifikat erfolgreich erstellt!
echo.
echo 📁 Dateien:
echo    Private Key: ssl-certs\chef.fritz.box.key
echo    Certificate: ssl-certs\chef.fritz.box.crt
echo.
echo 🔧 Für NPM Custom SSL Certificate:
echo.

echo === PRIVATE KEY (komplett kopieren) ===
type ssl-certs\chef.fritz.box.key
echo.
echo === CERTIFICATE (komplett kopieren) ===
type ssl-certs\chef.fritz.box.crt
echo.

echo 💡 Anleitung:
echo 1. NPM → SSL Certificates → Add SSL Certificate → Custom
echo 2. Name: chef.fritz.box-new
echo 3. Certificate Key: [Private Key von oben kopieren]
echo 4. Certificate: [Certificate von oben kopieren]
echo 5. Save
echo 6. Proxy Host aktualisieren um neues Zertifikat zu verwenden
echo.
echo ⚠️  Browser Warnung bei selbstsignierten Zertifikaten ist normal!
echo    Einfach 'Erweitert' → 'Trotzdem fortfahren' klicken.

pause
