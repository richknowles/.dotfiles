#!/bin/bash
# Okta Bug Bounty Recon Script
# Usage: ./okta-recon.sh [target-domain]

TARGET="${1:-okta.com}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="$HOME/bounty/okta/$TIMESTAMP"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ___  _    _           ____                      "
echo " / _ \| | _| |_ __ _   |  _ \ ___  ___ ___  _ __  "
echo "| | | | |/ / __/ _\` |  | |_) / _ \/ __/ _ \| '_ \ "
echo "| |_| |   <| || (_| |  |  _ <  __/ (_| (_) | | | |"
echo " \___/|_|\_\\__\__,_|  |_| \_\___|\___\___/|_| |_|"
echo -e "${NC}"
echo -e "${YELLOW}Target: $TARGET${NC}"
echo -e "${YELLOW}Output: $OUTDIR${NC}"
echo ""

mkdir -p "$OUTDIR"

# Subdomain enumeration
echo -e "${GREEN}[1/7] Subdomain enumeration...${NC}"
subfinder -d "$TARGET" -all -silent | sort -u > "$OUTDIR/subs-subfinder.txt"
echo "      Found $(wc -l < "$OUTDIR/subs-subfinder.txt") subdomains"

# Passive sources (wayback, gau)
echo -e "${GREEN}[2/7] Gathering URLs from passive sources...${NC}"
echo "$TARGET" | gau --threads 5 2>/dev/null | sort -u > "$OUTDIR/urls-gau.txt"
echo "$TARGET" | waybackurls 2>/dev/null | sort -u > "$OUTDIR/urls-wayback.txt"
cat "$OUTDIR/urls-gau.txt" "$OUTDIR/urls-wayback.txt" | sort -u > "$OUTDIR/urls-passive.txt"
echo "      Found $(wc -l < "$OUTDIR/urls-passive.txt") passive URLs"

# Extract subdomains from passive URLs
cat "$OUTDIR/urls-passive.txt" | unfurl -u domains 2>/dev/null | sort -u > "$OUTDIR/subs-passive.txt" 2>/dev/null || true

# Merge all subdomains
cat "$OUTDIR/subs-subfinder.txt" "$OUTDIR/subs-passive.txt" 2>/dev/null | sort -u > "$OUTDIR/subs-all.txt"
echo -e "${YELLOW}      Total unique subdomains: $(wc -l < "$OUTDIR/subs-all.txt")${NC}"

# Probe for live hosts
echo -e "${GREEN}[3/7] Probing live hosts...${NC}"
cat "$OUTDIR/subs-all.txt" | httpx -silent -title -status-code -tech-detect -follow-redirects -o "$OUTDIR/live-hosts.txt"
echo "      Found $(wc -l < "$OUTDIR/live-hosts.txt") live hosts"

# Extract just URLs for further processing
cat "$OUTDIR/live-hosts.txt" | awk '{print $1}' > "$OUTDIR/live-urls.txt"

# Port scanning (top ports, fast)
echo -e "${GREEN}[4/7] Quick port scan...${NC}"
naabu -list "$OUTDIR/subs-all.txt" -top-ports 100 -silent -o "$OUTDIR/ports.txt" 2>/dev/null || \
    echo "      (naabu skipped - may need root)"

# Nuclei scan
echo -e "${GREEN}[5/7] Running nuclei (this takes a while)...${NC}"
nuclei -l "$OUTDIR/live-urls.txt" -severity low,medium,high,critical -silent -o "$OUTDIR/nuclei-results.txt" 2>/dev/null
if [ -s "$OUTDIR/nuclei-results.txt" ]; then
    echo -e "${RED}      FINDINGS: $(wc -l < "$OUTDIR/nuclei-results.txt") potential issues!${NC}"
else
    echo "      No nuclei findings"
fi

# Crawl for endpoints
echo -e "${GREEN}[6/7] Crawling for endpoints...${NC}"
katana -list "$OUTDIR/live-urls.txt" -silent -d 3 -jc -o "$OUTDIR/endpoints-katana.txt" 2>/dev/null
echo "      Found $(wc -l < "$OUTDIR/endpoints-katana.txt") endpoints"

# Look for interesting patterns
echo -e "${GREEN}[7/7] Extracting interesting patterns...${NC}"

# Find potential API endpoints
grep -hiE "(api|graphql|v[0-9]|rest|oauth|auth|token|callback|redirect)" "$OUTDIR/endpoints-katana.txt" 2>/dev/null | sort -u > "$OUTDIR/interesting-api.txt"

# Find potential secrets/keys in JS
grep -hiE "(api_key|apikey|secret|token|password|aws|firebase)" "$OUTDIR/urls-passive.txt" 2>/dev/null | sort -u > "$OUTDIR/interesting-secrets.txt"

# Find redirect parameters
grep -hiE "(redirect|return|next|url|goto|dest|continue|rurl)" "$OUTDIR/endpoints-katana.txt" 2>/dev/null | sort -u > "$OUTDIR/interesting-redirects.txt"

echo ""
echo -e "${BLUE}=== Recon Complete ===${NC}"
echo ""
echo "Results saved to: $OUTDIR"
echo ""
echo "Key files to review:"
echo "  - live-hosts.txt        : Live hosts with tech stack"
echo "  - nuclei-results.txt    : Potential vulnerabilities"
echo "  - interesting-api.txt   : API endpoints to test"
echo "  - interesting-redirects.txt : Potential open redirects"
echo "  - endpoints-katana.txt  : All crawled endpoints"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review nuclei findings"
echo "  2. Test API endpoints in Burp"
echo "  3. Check redirect params for open redirect"
echo "  4. Look for IDOR in API endpoints"
echo "  5. Test OAuth/SAML flows manually"
echo ""
