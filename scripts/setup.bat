@echo off
REM Setup Script für Nginx Proxy Manager auf Raspberry Pi 5 (Windows Version)
REM Dieses Script bereitet die Konfiguration vor

echo === Nginx Proxy Manager Setup für Raspberry Pi 5 ===
echo.

REM Erstelle notwendige Verzeichnisse
echo Erstelle Verzeichnisse...
if not exist "config\nginx" mkdir "config\nginx"
if not exist "config\letsencrypt" mkdir "config\letsencrypt"
if not exist "data" mkdir "data"
if not exist "nginx-config\ssl" mkdir "nginx-config\ssl"

echo Verzeichnisse erstellt.
echo.

echo === Setup auf Windows abgeschlossen! ===
echo.
echo Nächste Schritte für den Raspberry Pi:
echo 1. Kopiere alle Dateien auf den Raspberry Pi
echo 2. Führe 'chmod +x scripts/setup.sh' aus
echo 3. Führe './scripts/setup.sh' aus
echo 4. Starte mit 'docker-compose up -d'
echo.
echo Für Windows-Test (ohne SSL):
echo 1. Bearbeite docker-compose.yml und entferne SSL-Konfiguration
echo 2. Führe 'docker-compose up -d' aus
echo 3. Öffne http://localhost:81
echo.

pause
