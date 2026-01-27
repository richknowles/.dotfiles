#!/bin/bash
# Bug Bounty Tool Installer
# Run this on a fresh Kali/Debian/Ubuntu VM

set -e

echo "=== Bug Bounty Toolkit Installer ==="

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Create directories
mkdir -p ~/tools ~/bounty ~/wordlists

# Update system
echo -e "${GREEN}[*] Updating system...${NC}"
sudo apt update && sudo apt upgrade -y

# Install base dependencies
echo -e "${GREEN}[*] Installing dependencies...${NC}"
sudo apt install -y \
    git curl wget \
    golang-go \
    python3 python3-pip python3-venv \
    jq \
    chromium \
    tmux \
    nmap \
    masscan \
    whois \
    dnsutils \
    net-tools

# Set Go path
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc

# ProjectDiscovery tools (the essentials)
echo -e "${GREEN}[*] Installing ProjectDiscovery suite...${NC}"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/notify/cmd/notify@latest
go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest

# Other essential tools
echo -e "${GREEN}[*] Installing additional tools...${NC}"
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/tomnomnom/gf@latest
go install -v github.com/tomnomnom/qsreplace@latest
go install -v github.com/tomnomnom/httprobe@latest
go install -v github.com/ffuf/ffuf/v2@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/hakluke/hakrawler@latest

# Update nuclei templates
echo -e "${GREEN}[*] Updating nuclei templates...${NC}"
nuclei -update-templates

# Download wordlists
echo -e "${GREEN}[*] Downloading wordlists...${NC}"
cd ~/wordlists
wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt
wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-20000.txt
wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt
wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-medium-directories.txt

# Clone useful repos
echo -e "${GREEN}[*] Cloning useful repos...${NC}"
cd ~/tools
git clone --depth 1 https://github.com/danielmiessler/SecLists.git 2>/dev/null || true
git clone --depth 1 https://github.com/swisskyrepo/PayloadsAllTheThings.git 2>/dev/null || true

# gf patterns (for grep pattern matching)
echo -e "${GREEN}[*] Setting up gf patterns...${NC}"
mkdir -p ~/.gf
git clone --depth 1 https://github.com/tomnomnom/gf.git /tmp/gf 2>/dev/null || true
cp /tmp/gf/examples/*.json ~/.gf/ 2>/dev/null || true

# Python tools
echo -e "${GREEN}[*] Installing Python tools...${NC}"
pip3 install --user arjun dirsearch

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Tools installed:"
echo "  - subfinder, httpx, nuclei, katana, naabu, dnsx (ProjectDiscovery)"
echo "  - ffuf, gau, waybackurls, gf, qsreplace, hakrawler (recon)"
echo "  - SecLists, PayloadsAllTheThings (wordlists)"
echo ""
echo "Run 'source ~/.bashrc' to update PATH"
echo "Run 'nuclei -update-templates' periodically"
echo ""
echo "Happy hunting!"
