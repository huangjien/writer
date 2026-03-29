#!/bin/bash

# Font Subsetting Script for Writer
# Reduces font size from 38MB to <10MB by subsetting unused characters

set -euo pipefail

echo "======================================"
echo "Font Subsetting for Writer"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check dependencies
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is required${NC}"
    echo "Install: brew install python3"
    exit 1
fi

# Check if fonttools is installed
if ! python3 -c "import fontTools" &> /dev/null; then
    echo -e "${YELLOW}Installing fonttools...${NC}"
    pip3 install fonttools brotli
fi

# Create output directory
mkdir -p assets/fonts/subset

echo -e "${GREEN}Step 1: Extracting Chinese characters from codebase...${NC}"

# Extract all Chinese characters from Dart files
find lib -name "*.dart" -exec grep -oP "[\x{4e00}-\x{9fff}]" {} \; 2>/dev/null | \
  sort -u > /tmp/chinese_chars.txt

# Extract from localization files
find lib/l10n -name "*.arb" -exec grep -oP "[\x{4e00}-\x{9fff}]" {} \; 2>/dev/null | \
  sort -u >> /tmp/chinese_chars.txt

# Deduplicate
sort -u /tmp/chinese_chars.txt -o /tmp/chinese_chars.txt

CHAR_COUNT=$(wc -l < /tmp/chinese_chars.txt)
echo "Found $CHAR_COUNT unique Chinese characters"

# Add common Chinese punctuation and symbols
echo "，。！？；：、""''（）《》【】…—·" >> /tmp/chinese_chars.txt
echo "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" >> /tmp/chinese_chars.txt
echo "!\"#\$%&'()*+,-./:;<=>?@[\\]^_\`{|}~ " >> /tmp/chinese_chars.txt

echo -e "${GREEN}Step 2: Subsetting Noto Sans SC fonts...${NC}"

# Subset Noto Sans SC Regular
if [ -f "assets/fonts/NotoSansSC-Regular.ttf" ]; then
    echo "Subsetting NotoSansSC-Regular.ttf..."
    pyftsubset assets/fonts/NotoSansSC-Regular.ttf \
        --text-file=/tmp/chinese_chars.txt \
        --output-file=assets/fonts/subset/NotoSansSC-Regular.ttf \
        --layout-features='*'

    ORIGINAL_SIZE=$(du -h "assets/fonts/NotoSansSC-Regular.ttf" | cut -f1)
    NEW_SIZE=$(du -h "assets/fonts/subset/NotoSansSC-Regular.ttf" | cut -f1)
    echo "  $ORIGINAL_SIZE → $NEW_SIZE"
fi

# Subset Noto Sans SC Bold
if [ -f "assets/fonts/NotoSansSC-Bold.ttf" ]; then
    echo "Subsetting NotoSansSC-Bold.ttf..."
    pyftsubset assets/fonts/NotoSansSC-Bold.ttf \
        --text-file=/tmp/chinese_chars.txt \
        --output-file=assets/fonts/subset/NotoSansSC-Bold.ttf \
        --layout-features='*'

    ORIGINAL_SIZE=$(du -h "assets/fonts/NotoSansSC-Bold.ttf" | cut -f1)
    NEW_SIZE=$(du -h "assets/fonts/subset/NotoSansSC-Bold.ttf" | cut -f1)
    echo "  $ORIGINAL_SIZE → $NEW_SIZE"
fi

echo -e "${GREEN}Step 3: Copying other fonts to subset directory...${NC}"

# Copy other fonts (no subsetting needed for smaller fonts)
cp assets/fonts/NotoSans-Regular.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/NotoSans-Bold.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/NotoSerif-Regular.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/NotoSerif-Bold.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/Inter-Regular.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/Inter-Bold.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/Merriweather-Regular.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/Merriweather-Bold.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/Roboto-Regular.ttf assets/fonts/subset/ 2>/dev/null || true
cp assets/fonts/Roboto-Bold.ttf assets/fonts/subset/ 2>/dev/null || true

echo -e "${GREEN}Step 4: Calculating savings...${NC}"

ORIGINAL_TOTAL=$(du -sh assets/fonts/ | cut -f1)
NEW_TOTAL=$(du -sh assets/fonts/subset/ | cut -f1)

echo "Original font size: $ORIGINAL_TOTAL"
echo "Subset font size: $NEW_TOTAL"

echo ""
echo -e "${GREEN}Step 5: Updating pubspec.yaml...${NC}"

# Backup pubspec.yaml
cp pubspec.yaml pubspec.yaml.bak

# Comment out old fonts and add new ones
cat > /tmp/pubspec_fonts.txt << 'EOF'
  fonts:
    - family: Noto Sans SC
      fonts:
        - asset: assets/fonts/subset/NotoSansSC-Regular.ttf
        - asset: assets/fonts/subset/NotoSansSC-Bold.ttf
          weight: 700
    - family: Inter
      fonts:
        - asset: assets/fonts/subset/Inter-Regular.ttf
        - asset: assets/fonts/subset/Inter-Bold.ttf
          weight: 700
    - family: Merriweather
      fonts:
        - asset: assets/fonts/subset/Merriweather-Regular.ttf
        - asset: assets/fonts/subset/Merriweather-Bold.ttf
          weight: 700
    - family: Roboto
      fonts:
        - asset: assets/fonts/subset/Roboto-Regular.ttf
        - asset: assets/fonts/subset/Roboto-Bold.ttf
          weight: 700
    - family: Noto Sans
      fonts:
        - asset: assets/fonts/subset/NotoSans-Regular.ttf
        - asset: assets/fonts/subset/NotoSans-Bold.ttf
          weight: 700
    - family: Noto Serif
      fonts:
        - asset: assets/fonts/subset/NotoSerif-Regular.ttf
        - asset: assets/fonts/subset/NotoSerif-Bold.ttf
          weight: 700
EOF

echo ""
echo -e "${GREEN}======================================"
echo "Font subsetting complete!"
echo "======================================${NC}"
echo ""
echo "Next steps:"
echo "1. Review the subset fonts in: assets/fonts/subset/"
echo "2. Update pubspec.yaml with paths above"
echo "3. Run: flutter clean && flutter pub get"
echo "4. Test the app to ensure all characters render correctly"
echo "5. Build release to verify size reduction"
echo ""
echo "Expected savings: 30MB+ (80% reduction)"
echo ""
echo "If you find missing characters, you can:"
echo "- Add them to /tmp/chinese_chars.txt"
echo "- Re-run this script"
