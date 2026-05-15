#!/bin/bash
# Validates dependencies for known vulnerabilities and license compliance

set -e

echo "🔍 Supply Chain Security Validation"
echo "=================================="
echo ""

# Check for package.json
if [ ! -f "package.json" ]; then
    echo "❌ No package.json found"
    exit 1
fi

echo "1. Running npm audit..."
echo "----------------------"
npm audit --audit-level=moderate || {
    echo ""
    echo "❌ npm audit found vulnerabilities"
    echo "Run 'npm audit fix' to attempt automatic fixes"
    echo ""
}

echo ""
echo "2. Checking for outdated packages..."
echo "------------------------------------"
npm outdated || echo "Some packages are outdated (this doesn't block deployment)"

echo ""
echo "3. Checking licenses..."
echo "-----------------------"
npx license-checker --summary

# Check for GPL licenses
if npx license-checker --json | jq -r '.[] | select(.licenses | contains("GPL"))' | grep -q .; then
    echo ""
    echo "❌ GPL license detected!"
    echo "GPL licenses may require open-sourcing your code."
    echo "Review license compatibility before deploying."
    exit 1
fi

echo "✅ No GPL licenses found"

echo ""
echo "4. Generating SBOM..."
echo "---------------------"
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
echo "✅ SBOM generated: sbom.json"

echo ""
echo "=================================="
echo "✅ Supply chain validation complete"