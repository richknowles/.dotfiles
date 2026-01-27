# Dotfiles & Bug Bounty Setup Session

**Date:** January 26, 2026
**Session:** Setting up dotfiles repo + bug bounty hunting toolkit

---

## Hardware Setup

| Machine | Specs | Purpose |
|---------|-------|---------|
| **P15 Gen 1 Laptop** | i7 10th Gen, 32GB RAM, 2x 1TB NVMe, Nvidia Quadro T1000 | Daily driver |
| **Tower (Proxmox)** | 5960X, ZFS | VMs, hunting box |
| **NVMe 1** | macOS Sonoma (OpenCore Hackintosh) | macOS testing |
| **NVMe 2** | Windows → Omarchy (pending) | Main Linux |

---

## What We Built

### Dotfiles Repository Structure

```
~/.dotfiles/
├── README.md              # Main documentation
├── install.sh             # Auto-symlink installer
├── .gitignore             # Ignores rclone creds
│
├── shell/                 # Shell configs
│   ├── bashrc             # Main bash config (cross-platform)
│   ├── bashrc.wsl         # WSL-specific bash
│   ├── bash_profile       # Login shell
│   ├── bash_logout.wsl
│   ├── profile.wsl
│   └── zshrc              # Zsh config (for Omarchy)
│
├── git/                   # Git configs
│   ├── gitconfig          # Main config with conditional includes
│   ├── gitconfig.macos    # macOS (osxkeychain)
│   ├── gitconfig.linux    # Linux
│   ├── gitconfig.wsl      # WSL (Windows credential manager)
│   └── gitignore_global   # Global ignores
│
├── vim/
│   └── vimrc              # Vim configuration
│
├── config/                # ~/.config files
│   ├── fish/              # Fish shell config
│   ├── neofetch/
│   ├── mc/                # Midnight Commander
│   └── rclone/            # (ignored - has creds)
│
├── wsl/                   # WSL-specific
│   ├── wsl.conf           # /etc/wsl.conf template
│   ├── .wslconfig         # Windows-side WSL2 config
│   └── .wsl-config        # Your custom config
│   └── README.md
│
├── windows/               # Windows configs
│   ├── collect-windows-configs.ps1
│   ├── Microsoft.PowerShell_profile.ps1
│   ├── windows-terminal.json
│   ├── vscode-settings.json
│   ├── vscode-extensions.txt
│   ├── gitconfig.windows
│   ├── scoop-packages.txt
│   └── README.md
│
└── scripts/
    ├── collect-wsl-configs.sh    # WSL config collector
    └── bounty/                   # Bug bounty toolkit
        ├── README.md
        ├── install-tools.sh      # Tool installer
        ├── recon.sh              # Generic recon
        └── okta-recon.sh         # Okta-specific recon
```

### GitHub Repository

- **URL:** https://github.com/richknowles/.dotfiles
- **Main branch:** `main` (merged and current)
- **Feature branch:** `claude/setup-dotfiles-repo-03y5s` (merged)

---

## Bug Bounty Toolkit

### Tools Installed by `install-tools.sh`

**ProjectDiscovery Suite:**
- subfinder - Subdomain enumeration
- httpx - HTTP probing
- nuclei - Vulnerability scanner
- katana - Web crawler
- naabu - Port scanner
- dnsx - DNS toolkit
- notify - Notifications
- interactsh-client - OOB testing

**Recon Tools:**
- ffuf - Fuzzer
- gau - GetAllURLs
- waybackurls - Wayback Machine URLs
- gf - Grep patterns
- qsreplace - Query string manipulation
- hakrawler - Crawler

**Wordlists:**
- SecLists
- PayloadsAllTheThings

### Recon Scripts

**Generic Recon:**
```bash
./recon.sh target.com program-name
```

**Okta-Specific:**
```bash
./okta-recon.sh okta.com
```

**Output Structure:**
```
~/bounty/
├── okta/
│   └── 20260127_143022/
│       ├── subs-all.txt
│       ├── live-hosts.txt
│       ├── nuclei-results.txt    # CHECK THIS FIRST!
│       ├── endpoints-katana.txt
│       ├── interesting-api.txt
│       └── interesting-redirects.txt
```

---

## Installation Commands

### On Any New Machine

```bash
git clone https://github.com/richknowles/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### On Proxmox Hunting VM

```bash
# Clone dotfiles
git clone https://github.com/richknowles/.dotfiles.git ~/.dotfiles

# Install bounty tools
cd ~/.dotfiles/scripts/bounty
./install-tools.sh
source ~/.bashrc

# Start hunting
tmux new -s recon
./okta-recon.sh okta.com
# Ctrl+B, D to detach
```

### On Windows (PowerShell)

```powershell
# Collect configs
& "\\wsl$\Ubuntu-22.04\home\rich\.dotfiles\windows\collect-windows-configs.ps1"
```

---

## Key Fixes Applied

1. **Fish shell syntax error** - Fixed brew shellenv (bash → fish syntax)
   ```fish
   # Wrong (bash)
   eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

   # Right (fish)
   eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
   ```

2. **rclone credentials** - Added to `.gitignore` (had Wasabi S3 keys)

3. **WSL distro name** - It's `Ubuntu-22.04` not `Ubuntu`

---

## Next Steps

### Tomorrow

- [ ] Backup verified with Kopia to Wasabi
- [ ] Nuke Windows on NVMe 2
- [ ] Install Omarchy
- [ ] Clone dotfiles, run install.sh
- [ ] Set up Proxmox hunting VM
- [ ] Run install-tools.sh on VM
- [ ] Start Okta recon

### Okta Hunting Focus Areas

1. **Authentication flows** - SAML, OAuth, OIDC
2. **API endpoints** - Look for IDOR
3. **Redirect parameters** - Open redirect bugs
4. **MFA bypass** - Downgrade attacks
5. **Admin console** - Privilege escalation

### Useful Commands

```bash
# Quick subdomain + probe
subfinder -d okta.com -silent | httpx -silent

# Nuclei scan
nuclei -l urls.txt -severity high,critical

# Find interesting params
cat endpoints.txt | grep -iE "(redirect|token|api)"

# Run in background
tmux new -s hunting
./okta-recon.sh
# Ctrl+B, D to detach
# tmux attach -t hunting (to reconnect)
```

---

## Security Notes

**Never commit:**
- Private SSH keys (`~/.ssh/id_*`)
- API tokens / credentials
- `.env` files
- `rclone.conf` with passwords
- `.claude.json` (has tokens)

**Rotate these keys (exposed in terminal):**
- Wasabi S3 access keys (were visible in rclone.conf output)

---

## Platform Detection

The shell configs auto-detect platform:

| Platform | Detection | Adjustments |
|----------|-----------|-------------|
| macOS | `uname -s = Darwin` | Homebrew paths, `-G` for ls |
| Linux | `uname -s = Linux` | `--color=auto` |
| WSL | `/proc/version` contains "microsoft" | Windows interop aliases |

---

## Contacts & Resources

- **Bugcrowd:** https://bugcrowd.com
- **Okta Bug Bounty:** Check Bugcrowd for scope
- **Dotfiles Repo:** https://github.com/richknowles/.dotfiles

---

## Session Stats

- Dotfiles structure: Created
- Shell configs: bash, zsh, fish
- Platform support: macOS, Linux, WSL, Windows
- Bounty scripts: 4 files
- Tools to install: 20+
- Ready to hunt: YES

---

*Generated during Claude Code session - January 26, 2026*
