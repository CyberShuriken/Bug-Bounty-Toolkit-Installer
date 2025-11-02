#!/bin/bash

set -e

echo "[+] Updating system..."
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y

echo "[+] Installing dependencies..."
sudo apt install -y \
    curl wget git unzip jq build-essential python3 python3-pip python3-venv \
    ruby ruby-dev libssl-dev zlib1g-dev libffi-dev \
    seclists chromium burpsuite docker.io docker-compose \
    nmap sqlmap gobuster eyewitness enum4linux smbclient \
    openvpn wireguard net-tools ffuf amass sublist3r feroxbuster \
    nikto dirsearch whatweb wafw00f wireshark \
    gnome-terminal terminator default-jdk adb apktool jadx

echo "[+] Creating /opt if it doesn't exist..."
sudo mkdir -p /opt && sudo chown "$USER":"$USER" /opt

echo "[+] Installing Go..."
GO_VERSION=1.22.2
wget -q https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.zshrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

echo "[+] Installing pipx (with system bypass)..."
sudo apt install -y pipx || python3 -m pip install --break-system-packages pipx
pipx ensurepath

# Tools via Go
echo "[+] Installing Go tools..."
go install github.com/hakluke/hakrawler@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/OJ/gobuster@latest
go install github.com/ffuf/ffuf@latest
go install github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/hahwul/dalfox/v2@latest
go install github.com/1ndianl33t/Gf-Patterns@latest

echo "[+] Installing waybackurls manually (pip fallback)..."
mkdir -p /opt/tools && cd /opt/tools
git clone https://github.com/tomnomnom/waybackurls.git && cd waybackurls
go build -o waybackurls
sudo mv waybackurls /usr/local/bin/
cd ~ || exit

# Tools via pipx
echo "[+] Installing pipx tools..."
pipx install uro || echo "[!] Failed: uro"
pipx install mitmproxy || echo "[!] Failed: mitmproxy"
pipx install arjun || echo "[!] Failed: arjun"
pipx install kiterunner || echo "[!] Failed: kiterunner"

# Tools via GitHub clones (that don’t need compilation)
echo "[+] Cloning GitHub tools into /opt..."
cd /opt/tools || exit

[[ ! -d "XSStrike" ]] && git clone https://github.com/s0md3v/XSStrike.git
[[ ! -d "GF-Patterns" ]] && git clone https://github.com/1ndianl33t/Gf-Patterns.git
[[ ! -d "commix" ]] && git clone https://github.com/commixproject/commix.git
[[ ! -d "sqliv" ]] && git clone https://github.com/Hadesy2k/sqliv.git

# Burp Suite Extensions (via BApp or manual)
echo "[+] Preparing Burp extensions..."
mkdir -p /opt/burp-extensions
cd /opt/burp-extensions || exit

BURP_EXT_URLS=(
  "https://portswigger.net/bappstore/7a0286ff623b4f6f8c2782bc1b3ae67e.bapp"  # Autorize
  "https://portswigger.net/bappstore/347ae44936ae42e5ae4da1e3f3c4f2b3.bapp"  # Reflector
)
for url in "${BURP_EXT_URLS[@]}"; do
  wget -nc "$url"
done

# Browser Extensions (manual download needed)
echo "[+] Please manually install browser extensions:"
echo "  - Wappalyzer"
echo "  - Shodan"
echo "  - HackTools"
echo "  - Cookie-Editor"

echo "[\u2713] All tools are set up!"
echo "=> Restart terminal or run: source ~/.bashrc or ~/.zshrc"
