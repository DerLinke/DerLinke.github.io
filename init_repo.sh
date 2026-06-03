#!/bin/bash
# Skript zur Initialisierung des zentralen Repositories

REPO_DIR="/home/dan/Projekte/DerLinke-Repo"
mkdir -p "$REPO_DIR/pool/main"
mkdir -p "$REPO_DIR/dists/stable/main/binary-amd64"

# Kopiere vorhandene .deb Pakete (vorerst manuell gesammelt)
echo "󰚌 Sammle Pakete..."
cp /home/dan/Projekte/findeb/findeb_1.1.0_amd64.deb "$REPO_DIR/pool/main/" 2>/dev/null || true

# Erstelle APT-Indexe
echo "󰚌 Generiere APT-Indexe..."
cd "$REPO_DIR"
dpkg-scanpackages --arch amd64 pool/main > dists/stable/main/binary-amd64/Packages
gzip -k -f dists/stable/main/binary-amd64/Packages

# Erstelle Release-Datei
cat <<EOF > dists/stable/Release
Origin: DerLinke
Label: DerLinke Software Repository
Suite: stable
Codename: stable
Architectures: amd64
Components: main
Description: Zentrales Repository für FinDeb, MyDash und Ultimate-Debian-Updater
EOF

# Füge Hash-Werte zur Release-Datei hinzu (einfache Version)
cd dists/stable
echo "MD5Sum:" >> Release
for f in main/binary-amd64/Packages*; do
    echo " $(md5sum $f | cut -d' ' -f1) $(stat -c%s $f) $f" >> Release
done

echo "✅ Repository-Struktur lokal vorbereitet in $REPO_DIR"
