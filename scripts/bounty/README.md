# Bug Bounty Toolkit

Scripts and tools for bug bounty hunting.

## Setup

Run on a fresh Kali/Debian/Ubuntu VM (or your Proxmox hunting box):

```bash
chmod +x install-tools.sh
./install-tools.sh
source ~/.bashrc
```

## Scripts

### `install-tools.sh`
Installs all the essential tools:
- **ProjectDiscovery**: subfinder, httpx, nuclei, katana, naabu, dnsx
- **Recon**: ffuf, gau, waybackurls, gf, hakrawler
- **Wordlists**: SecLists, PayloadsAllTheThings

### `recon.sh`
Generic recon for any target:
```bash
./recon.sh example.com program-name
```

### `okta-recon.sh`
Okta-specific recon:
```bash
./okta-recon.sh okta.com
```

## Directory Structure

After running recon, results are in:
```
~/bounty/
├── okta/
│   └── 20260127_143022/
│       ├── subs-all.txt          # All subdomains
│       ├── live-hosts.txt        # Live hosts + tech
│       ├── nuclei-results.txt    # Vulnerabilities!
│       ├── endpoints-katana.txt  # Crawled endpoints
│       ├── interesting-api.txt   # API endpoints
│       └── interesting-redirects.txt
└── other-program/
    └── ...
```

## Workflow

1. **Recon** (run on Proxmox VM, let it cook)
   ```bash
   tmux new -s recon
   ./okta-recon.sh okta.com
   # Ctrl+B, D to detach
   ```

2. **Review** nuclei findings first (low hanging fruit)

3. **Manual testing** in Burp Suite (on laptop)
   - API endpoints
   - OAuth flows
   - Redirect params

4. **Report** findings on Bugcrowd

## Tips

- Run recon in `tmux` so it persists
- Check `nuclei-results.txt` first - easy wins
- Look for IDOR in API endpoints (`/api/v1/users/123`)
- Test redirect params for open redirect
- Always check OAuth/SAML flows manually

## Useful One-Liners

```bash
# Find all JS files
cat endpoints.txt | grep -E "\.js$" | sort -u

# Find potential secrets in URLs
cat urls-passive.txt | grep -iE "(key|token|secret|pass)"

# Quick subdomain takeover check
nuclei -l subs.txt -t http/takeovers/

# Parameter discovery
cat endpoints.txt | grep "?" | qsreplace FUZZ | sort -u

# Check for open redirects
cat endpoints.txt | grep -iE "(redirect|return|next|url|goto)" | qsreplace "https://evil.com"
```

## Stay Updated

```bash
# Update nuclei templates regularly
nuclei -update-templates

# Update tools
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

Happy hunting! 💰
