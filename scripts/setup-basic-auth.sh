#!/bin/bash

# Basic Auth Setup Script für Nginx Proxy Manager
# Erstellt oder aktualisiert die Basic Auth Datei

echo "🔒 Basic Authentication für Nginx Proxy Manager"
echo "=============================================="

# Überprüfe ob htpasswd verfügbar ist
if ! command -v htpasswd &> /dev/null; then
    echo "❌ htpasswd ist nicht installiert!"
    echo "💡 Installiere apache2-utils:"
    echo "   sudo apt-get update && sudo apt-get install -y apache2-utils"
    exit 1
fi

# Erstelle nginx-config Verzeichnis falls nicht vorhanden
mkdir -p ./nginx-config/custom

# Prüfe ob .htpasswd bereits existiert
if [ -f "./nginx-config/custom/.htpasswd" ]; then
    echo "⚠️ Basic Auth Datei existiert bereits."
    echo "Möchtest du:"
    echo "1) Passwort für 'admin' ändern"
    echo "2) Neuen Benutzer hinzufügen"
    echo "3) Datei komplett neu erstellen"
    echo "4) Abbrechen"
    read -p "Wähle (1-4): " choice
    
    case $choice in
        1)
            echo "🔧 Ändere Passwort für Benutzer 'admin'..."
            htpasswd ./nginx-config/custom/.htpasswd admin
            ;;
        2)
            echo "👤 Neuen Benutzer hinzufügen..."
            read -p "Benutzername: " username
            htpasswd ./nginx-config/custom/.htpasswd "$username"
            ;;
        3)
            echo "🆕 Erstelle neue Basic Auth Datei..."
            rm ./nginx-config/custom/.htpasswd
            ;;
        4)
            echo "❌ Abgebrochen."
            exit 0
            ;;
        *)
            echo "❌ Ungültige Auswahl."
            exit 1
            ;;
    esac
fi

# Erstelle neue .htpasswd Datei falls nicht vorhanden
if [ ! -f "./nginx-config/custom/.htpasswd" ]; then
    echo ""
    echo "🆕 Erstelle neue Basic Auth Datei..."
    echo "Benutzername: admin"
    
    # Verbesserte Passwort-Eingabe
    auth_success=false
    retry_count=0
    max_retries=3
    
    while [ "$auth_success" = false ] && [ $retry_count -lt $max_retries ]; do
        echo ""
        echo "Versuch $((retry_count + 1)) von $max_retries"
        echo "Passwort-Anforderungen:"
        echo "- Mindestens 8 Zeichen"
        echo "- Empfohlen: Groß-/Kleinbuchstaben, Zahlen, Sonderzeichen"
        
        # Passwort ohne Echo eingeben
        read -s -p "Neues Passwort: " password1
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
        
        # Erstelle htpasswd Datei mit bcrypt (sicherer)
        if echo "$password1" | htpasswd -c -i -B ./nginx-config/custom/.htpasswd admin 2>/dev/null; then
            echo "✅ Basic Auth erfolgreich erstellt mit bcrypt Verschlüsselung!"
            auth_success=true
        elif echo "$password1" | htpasswd -c -i ./nginx-config/custom/.htpasswd admin 2>/dev/null; then
            echo "✅ Basic Auth erfolgreich erstellt!"
            auth_success=true
        else
            echo "❌ Fehler beim Erstellen der Basic Auth Datei!"
            retry_count=$((retry_count + 1))
        fi
        
        # Passwort-Variablen sicher löschen
        unset password1
        unset password2
    done
    
    if [ "$auth_success" = false ]; then
        echo ""
        echo "❌ Basic Auth konnte nach $max_retries Versuchen nicht erstellt werden."
        echo ""
        echo "💡 Mögliche Lösungen:"
        echo "1. Prüfe ob apache2-utils installiert ist:"
        echo "   sudo apt-get install apache2-utils"
        echo ""
        echo "2. Erstelle manuell mit einfacherem Befehl:"
        echo "   htpasswd -c -B ./nginx-config/.htpasswd admin"
        echo ""
        echo "3. Verwende Online htpasswd Generator und kopiere Ergebnis in:"
        echo "   ./nginx-config/.htpasswd"
        exit 1
    fi
fi

# Setze korrekte Berechtigungen
chmod 644 ./nginx-config/custom/.htpasswd

echo ""
echo "✅ Basic Auth Setup abgeschlossen!"
echo ""
echo "📁 Datei: ./nginx-config/custom/.htpasswd"
echo "👤 Benutzer: admin"
echo ""
echo "🔧 Weitere Aktionen:"
echo "- Passwort ändern: htpasswd ./nginx-config/custom/.htpasswd admin"
echo "- Benutzer hinzufügen: htpasswd ./nginx-config/custom/.htpasswd BENUTZERNAME"
echo "- Benutzer löschen: htpasswd -D ./nginx-config/custom/.htpasswd BENUTZERNAME"
echo "- Datei anzeigen: cat ./nginx-config/custom/.htpasswd"
echo ""
echo "🔄 Nach Änderungen Container neu starten:"
echo "   docker compose restart nginx-proxy-manager"
