#!/bin/bash
# Generic Bug Bounty Recon Script
# Usage: ./recon.sh <target-domain> [program-name]

if [ -z "$1" ]; then
    echo "Usage: $0 <target-domain> [program-name]"
    echo "Example: $0 example.com acme-corp"
    exit 1
fi

TARGET="$1"
PROGRAM="${2:-$TARGET}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="$HOME/bounty/$PROGRAM/$TIMESTAMP"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Recon: $TARGET ===${NC}"
echo "Output: $OUTDIR"
echo ""

mkdir -p "$OUTDIR"

# Subdomain enum
echo -e "${GREEN}[*] Subdomain enumeration...${NC}"
subfinder -d "$TARGET" -all -silent 2>/dev/null | sort -u > "$OUTDIR/subs.txt"
echo "    Subfinder: $(wc -l < "$OUTDIR/subs.txt") subs"

# Probe live
echo -e "${GREEN}[*] Probing live hosts...${NC}"
cat "$OUTDIR/subs.txt" | httpx -silent -title -status-code -tech-detect -o "$OUTDIR/live.txt" 2>/dev/null
cat "$OUTDIR/live.txt" | awk '{print $1}' > "$OUTDIR/live-urls.txt"
echo "    Live: $(wc -l < "$OUTDIR/live-urls.txt") hosts"

# Passive URLs
echo -e "${GREEN}[*] Passive URL collection...${NC}"
echo "$TARGET" | gau --threads 5 2>/dev/null | sort -u > "$OUTDIR/urls-passive.txt"
echo "    URLs: $(wc -l < "$OUTDIR/urls-passive.txt")"

# Crawl
echo -e "${GREEN}[*] Crawling endpoints...${NC}"
katana -list "$OUTDIR/live-urls.txt" -silent -d 2 -jc -o "$OUTDIR/endpoints.txt" 2>/dev/null
echo "    Endpoints: $(wc -l < "$OUTDIR/endpoints.txt")"

# Nuclei
echo -e "${GREEN}[*] Nuclei scan...${NC}"
nuclei -l "$OUTDIR/live-urls.txt" -severity medium,high,critical -silent -o "$OUTDIR/nuclei.txt" 2>/dev/null
if [ -s "$OUTDIR/nuclei.txt" ]; then
    echo -e "${RED}    FINDINGS: $(wc -l < "$OUTDIR/nuclei.txt")${NC}"
    cat "$OUTDIR/nuclei.txt"
fi

# Interesting stuff
echo -e "${GREEN}[*] Extracting interesting patterns...${NC}"
grep -hiE "(api|v[0-9]|graphql|rest|admin|internal|staging|dev)" "$OUTDIR/endpoints.txt" 2>/dev/null | sort -u > "$OUTDIR/interesting.txt"
grep -hiE "\.(json|xml|yaml|yml|config|conf|bak|backup|old|log|sql)$" "$OUTDIR/endpoints.txt" 2>/dev/null | sort -u > "$OUTDIR/sensitive-files.txt"

echo ""
echo -e "${GREEN}=== Done ===${NC}"
echo "Results: $OUTDIR"
ls -la "$OUTDIR"
