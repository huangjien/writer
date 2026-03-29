#!/bin/bash

# Simple Font Subsetting Script for Writer
# Reduces font size from 38MB to <10MB by subsetting unused characters

set -euo pipefail

echo "======================================"
echo "Simple Font Subsetting for Writer"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create output directory
mkdir -p assets/fonts/subset

echo -e "${GREEN}Step 1: Extracting Chinese characters from localization...${NC}"

# Extract Chinese characters from ARB files
find lib/l10n -name "*.arb" -exec grep -oP "[\x{4e00}-\x{9fff}]" {} \; 2>/dev/null | \
  sort -u > /tmp/chinese_chars.txt

# Add common Chinese punctuation
echo "，。！？；：、""''（）《》【】…—·" >> /tmp/chinese_chars.txt

# Add ASCII
echo "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#\$%&'()*+,-./:;<=>?@[\\]^_\`{|}~ " >> /tmp/chinese_chars.txt

CHAR_COUNT=$(wc -l < /tmp/chinese_chars.txt)
echo "Found $CHAR_COUNT unique characters"

echo -e "${GREEN}Step 2: Creating character text file for fontTools...${NC}"

# Create a simple text file with all characters
tr -d '\n' < /tmp/chinese_chars.txt > /tmp/chinese_chars_oneline.txt

echo -e "${GREEN}Step 3: Subsetting Noto Sans SC fonts...${NC}"

# Activate virtual environment
if [ -f ".venv/bin/activate" ]; then
    echo "Activating virtual environment..."
    source .venv/bin/activate
fi

# Check if pyftsubset is available
if ! command -v pyftsubset &> /dev/null; then
    echo -e "${YELLOW}pyftsubset not found. Installing fonttools in venv...${NC}"
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        pip install fonttools
    else
        echo "Error: Virtual environment not found. Please run: python3 -m venv .venv"
        exit 1
    fi
fi

# Subset Noto Sans SC Regular
if [ -f "assets/fonts/NotoSansSC-Regular.ttf" ]; then
    echo "Subsetting NotoSansSC-Regular.ttf..."
    pyftsubset assets/fonts/NotoSansSC-Regular.ttf \
        --text-file=/tmp/chinese_chars_oneline.txt \
        --output-file=assets/fonts/subset/NotoSansSC-Regular.ttf \
        --layout-features='*'

    if [ -f "assets/fonts/subset/NotoSansSC-Regular.ttf" ]; then
        ORIGINAL_SIZE=$(du -h "assets/fonts/NotoSansSC-Regular.ttf" | cut -f1)
        NEW_SIZE=$(du -h "assets/fonts/subset/NotoSansSC-Regular.ttf" | cut -f1)
        echo "  $ORIGINAL_SIZE → $NEW_SIZE ✓"
    else
        echo "  Failed to create subset font"
        exit 1
    fi
fi

# Subset Noto Sans SC Bold
if [ -f "assets/fonts/NotoSansSC-Bold.ttf" ]; then
    echo "Subsetting NotoSansSC-Bold.ttf..."
    pyftsubset assets/fonts/NotoSansSC-Bold.ttf \
        --text-file=/tmp/chinese_chars_oneline.txt \
        --output-file=assets/fonts/subset/NotoSansSC-Bold.ttf \
        --layout-features='*'

    if [ -f "assets/fonts/subset/NotoSansSC-Bold.ttf" ]; then
        ORIGINAL_SIZE=$(du -h "assets/fonts/NotoSansSC-Bold.ttf" | cut -f1)
        NEW_SIZE=$(du -h "assets/fonts/subset/NotoSansSC-Bold.ttf" | cut -f1)
        echo "  $ORIGINAL_SIZE → $NEW_SIZE ✓"
    else
        echo "  Failed to create subset font"
        exit 1
    fi
fi

echo -e "${GREEN}Step 4: Copying other fonts to subset directory...${NC}"

# Copy other fonts (no subsetting needed)
for font in assets/fonts/*.ttf; do
    if [ -f "$font" ]; then
        filename=$(basename "$font")
        if [ ! -f "assets/fonts/subset/$filename" ]; then
            cp "$font" assets/fonts/subset/
            echo "  Copied $filename"
        fi
    fi
done

echo -e "${GREEN}Step 5: Calculating savings...${NC}"

ORIGINAL_TOTAL=$(du -sh assets/fonts/ | cut -f1)
NEW_TOTAL=$(du -sh assets/fonts/subset/ | cut -f1)

echo ""
echo "Original font size: $ORIGINAL_TOTAL"
echo "Subset font size: $NEW_TOTAL"

echo ""
echo -e "${GREEN}======================================"
echo "Font subsetting complete!"
echo "======================================${NC}"
echo ""
echo "Subset fonts created in: assets/fonts/subset/"
echo ""
echo "To use the subset fonts:"
echo ""
echo "1. Update pubspec.yaml:"
echo ""
echo "  fonts:"
echo "    - family: Noto Sans SC"
echo "      fonts:"
echo "        - asset: assets/fonts/subset/NotoSansSC-Regular.ttf"
echo "        - asset: assets/fonts/subset/NotoSansSC-Bold.ttf"
echo "          weight: 700"
echo ""
echo "2. Clean and rebuild:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   ./scripts/build_optimized.sh android"
echo ""
echo "Expected savings: 30MB+ (80% reduction)"
echo ""
echo "⚠️  Test thoroughly to ensure all characters render correctly!"
