#!/bin/bash
# Stores SBOM in artifact repository with versioning

set -e

APP_NAME="${1:-sensor-data-api}"
APP_VERSION="${2:-$(jq -r .version package.json)}"
SBOM_DIR="${3:-sbom/output}"
STORAGE_BASE="${4:-sbom/storage}"

echo "Storing SBOM for $APP_NAME v$APP_VERSION"
echo ""

# Create version-specific storage directory
VERSION_DIR="$STORAGE_BASE/$APP_NAME/$APP_VERSION"
mkdir -p "$VERSION_DIR"

# Copy all SBOM files
echo "1. Copying SBOM files..."
cp "$SBOM_DIR"/* "$VERSION_DIR/" 2>/dev/null || {
    echo "❌ No SBOM files found in $SBOM_DIR"
    exit 1
}

echo "✅ Files copied to $VERSION_DIR"

# Create latest symlink
echo "2. Updating 'latest' pointer..."
LATEST_LINK="$STORAGE_BASE/$APP_NAME/latest"
rm -f "$LATEST_LINK"
ln -s "$APP_VERSION" "$LATEST_LINK"

echo "✅ Latest pointer updated"

# Generate index
echo "3. Updating version index..."
INDEX_FILE="$STORAGE_BASE/$APP_NAME/versions.json"

if [ -f "$INDEX_FILE" ]; then
    # Update existing index
    jq --arg version "$APP_VERSION" \
       --arg date "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '. + [{version: $version, date: $date}]' \
       "$INDEX_FILE" > "${INDEX_FILE}.tmp"
    mv "${INDEX_FILE}.tmp" "$INDEX_FILE"
else
    # Create new index
    jq -n --arg version "$APP_VERSION" \
          --arg date "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
          '[{version: $version, date: $date}]' > "$INDEX_FILE"
fi

echo "✅ Version index updated"

# Sign SBOM (if GPG available)
echo "4. Signing SBOM..."
if command -v gpg &> /dev/null; then
    for file in "$VERSION_DIR"/*.json "$VERSION_DIR"/*.xml; do
        [ -f "$file" ] && gpg --detach-sign --armor "$file" 2>/dev/null && \
            echo "✅ Signed: $(basename "$file")"
    done
else
    echo "⚠️  GPG not available, skipping signatures"
fi

echo ""
echo "=================================="
echo "SBOM stored successfully!"
echo "Location: $VERSION_DIR"
echo ""
echo "Access via:"
echo "  Version-specific: $VERSION_DIR"
echo "  Latest: $LATEST_LINK"