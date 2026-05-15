#!/bin/bash
# Generates Software Bill of Materials (SBOM) for the application

set -e

APP_NAME="${1:-sensor-data-api}"
APP_VERSION="${2:-$(jq -r .version package.json)}"
BUILD_ID="${3:-build-$(date +%s)}"
OUTPUT_DIR="${4:-sbom/output}"

echo "Generating SBOM for $APP_NAME v$APP_VERSION"
echo "Build ID: $BUILD_ID"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate CycloneDX SBOM (JSON format)
echo "1. Generating CycloneDX SBOM (JSON)..."
npx @cyclonedx/cyclonedx-npm \
  --output-format JSON \
  --output-file "$OUTPUT_DIR/${APP_NAME}-${APP_VERSION}-cyclonedx.json"

echo "✅ CycloneDX JSON generated"

# Generate CycloneDX SBOM (XML format)
echo "2. Generating CycloneDX SBOM (XML)..."
npx @cyclonedx/cyclonedx-npm \
  --output-format XML \
  --output-file "$OUTPUT_DIR/${APP_NAME}-${APP_VERSION}-cyclonedx.xml"

echo "✅ CycloneDX XML generated"

# Generate SPDX SBOM
echo "3. Generating SPDX SBOM..."
npx @spdx/spdx-sbom-generator npm \
  -o "$OUTPUT_DIR/${APP_NAME}-${APP_VERSION}-spdx.json" || {
    echo "⚠️  SPDX generation not available, skipping"
  }

# Generate human-readable summary
echo "4. Generating human-readable summary..."

TOTAL_DEPS=$(jq '.components | length' "$OUTPUT_DIR/${APP_NAME}-${APP_VERSION}-cyclonedx.json")
DIRECT_DEPS=$(jq '.dependencies[0].dependsOn | length' "$OUTPUT_DIR/${APP_NAME}-${APP_VERSION}-cyclonedx.json")

cat > "$OUTPUT_DIR/${APP_NAME}-${APP_VERSION}-summary.txt" <<EOF
Software Bill of Materials (SBOM)
==================================

Application: $APP_NAME
Version: $APP_VERSION
Build Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Build ID: $BUILD_ID
Git Commit: $(git rev-parse --short HEAD 2>/dev/null || echo "N/A")
SBOM Format: CycloneDX 1.4

Total Components: $TOTAL_DEPS
- Direct dependencies: $DIRECT_DEPS
- Transitive dependencies: $((TOTAL_DEPS - DIRECT_DEPS))

Generated: $(date)
EOF

echo "✅ Summary generated"

# Add metadata file
echo "5. Creating metadata..."
cat > "$OUTPUT_DIR/${APP_NAME}-${APP_VERSION}-metadata.json" <<EOF
{
  "application": "$APP_NAME",
  "version": "$APP_VERSION",
  "buildId": "$BUILD_ID",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "gitCommit": "$(git rev-parse HEAD 2>/dev/null || echo "unknown")",
  "gitBranch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")",
  "sbomFormats": [
    "cyclonedx-json",
    "cyclonedx-xml",
    "spdx-json"
  ],
  "totalComponents": $TOTAL_DEPS,
  "directDependencies": $DIRECT_DEPS
}
EOF

echo "✅ Metadata created"

echo ""
echo "=================================="
echo "SBOM generation complete!"
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Files generated:"
ls -lh "$OUTPUT_DIR"