#!/bin/bash
# Skript zur Initialisierung des zentralen Repositories
# Behebt APT-Sicherheitswarnungen durch starke Hashes und Datumsangaben

REPO_DIR="/home/dan/Projekte/DerLinke.github.io"
mkdir -p "$REPO_DIR/pool/main"
mkdir -p "$REPO_DIR/dists/stable/main/binary-amd64"

# Kopiere vorhandene .deb Pakete
echo "󰚌 Sammle Pakete..."
# Vorher aufräumen, um keine alten Versionen zu behalten
rm -f "$REPO_DIR/pool/main/"*.deb

cp /home/dan/Projekte/findeb/findeb*.deb "$REPO_DIR/pool/main/" 2>/dev/null || true
cp /home/dan/Projekte/Ultimate-Debian-Updater/ultimate-debian-updater*.deb "$REPO_DIR/pool/main/" 2>/dev/null || true
cp /home/dan/Projekte/mydash/mydash*.deb "$REPO_DIR/pool/main/" 2>/dev/null || true
cp /home/dan/Projekte/gAlert/galert*.deb "$REPO_DIR/pool/main/" 2>/dev/null || true

# Erstelle APT-Indexe
echo "󰚌 Generiere APT-Indexe..."
cd "$REPO_DIR"
dpkg-scanpackages --arch amd64 pool/main > dists/stable/main/binary-amd64/Packages
gzip -k -f dists/stable/main/binary-amd64/Packages

# Erstelle Release-Datei mit Datum und starken Hashes
echo "󰚌 Erstelle Release-Datei..."
cat <<EOF > dists/stable/Release
Origin: DerLinke
Label: DerLinke Software Repository
Suite: stable
Codename: stable
Date: $(date -uR)
Architectures: amd64
Components: main
Description: Zentrales Repository für FinDeb, MyDash, gAlert und Ultimate-Debian-Updater
EOF

# Hilfsfunktion für Hashes
generate_hashes() {
    local algo=$1
    local label=$2
    echo "$label:" >> Release
    for f in main/binary-amd64/Packages*; do
        case $algo in
            md5) hash=$(md5sum $f | cut -d' ' -f1) ;;
            sha256) hash=$(sha256sum $f | cut -d' ' -f1) ;;
        esac
        size=$(stat -c%s $f)
        echo " $hash $size $f" >> Release
    done
}

cd dists/stable
generate_hashes md5 "MD5Sum"
generate_hashes sha256 "SHA256"

echo "✅ Repository-Struktur lokal vorbereitet in $REPO_DIR"
