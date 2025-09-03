# Nginx Proxy Manager für Raspberry Pi 5

## Projekt Übersicht
- [x] Clarify Project Requirements - Nginx Proxy Manager Docker Setup für Raspberry Pi 5
- [x] Scaffold the Project - Projektstruktur und Docker-Konfiguration erstellt
- [x] Customize the Project - Sichere HTTPS-Konfiguration mit beiden Domains
- [ ] Install Required Extensions - Keine VS Code Extensions erforderlich
- [ ] Compile the Project - Docker-basiert, keine Kompilierung nötig
- [x] Create and Run Task - Setup Scripts für Pi und Windows erstellt
- [ ] Launch the Project - Bereit für Deployment auf Raspberry Pi
- [x] Ensure Documentation is Complete - Umfassende README erstellt

## Projekt Details
- **Zielplattform**: Raspberry Pi 5
- **Externe DNS**: myhomeassi23.ddns.net (Let's Encrypt SSL)
- **Interne DNS**: chef.fritz.box (Selbstsignierte SSL)
- **Hostname**: chef
- **Protokoll**: Nur HTTPS mit Basic Auth + Security Headers
- **Container**: Docker Compose mit gemounteten Konfigurationsdateien

## Erstellte Dateien
- docker-compose.yml (Haupt-Container-Konfiguration)
- nginx-config/default.conf (Sichere HTTPS-Konfiguration)
- scripts/pi-full-setup.sh (Komplette Pi Installation von Grund auf)
- scripts/start-nginx.sh (Container Start nach Neuboot)
- scripts/setup.sh (Basis Setup für vorbereitete Pi)
- scripts/setup.bat (Windows Vorbereitung)
- docs/pi-installation.md (Detaillierte Pi Setup Anleitung)
- README.md (Vollständige Dokumentation)
- .env.example (Konfigurationstemplate)
- .gitignore (Git-Ausschlüsse)
