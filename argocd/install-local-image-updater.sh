#!/bin/bash
set -e

URL="https://github.com/argoproj-labs/argocd-image-updater/releases/download/v1.1.1/argocd-image-updater-darwin_amd64"
DEST="$HOME/.local/bin/argocd-image-updater"

curl -L "$URL" -o /tmp/argocd-image-updater
chmod +x /tmp/argocd-image-updater
xattr -d com.apple.quarantine /tmp/argocd-image-updater 2>/dev/null || true
mkdir -p "$HOME/.local/bin"
mv /tmp/argocd-image-updater "$DEST"

echo "설치 완료: $DEST"
argocd-image-updater version
