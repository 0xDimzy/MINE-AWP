# AWP MineWork Multi Wallet Setup Guide (Hybrid Version)

Hybrid multi wallet setup using:

- Shared global installation
- Isolated wallet identities
- Lower RAM & storage usage
- Faster deployment
- Better scalability

Based on:
- `awp-wallet`
- `awp-skill`
- `mine-skill`

This version is optimized for:
- VPS
- Codespaces
- Multi account farming
- Low resource servers

---

# Features

✅ Shared global repositories  
✅ Shared Python environment  
✅ Shared Mine Skill installation  
✅ Isolated wallet identities  
✅ Multi wallet support  
✅ PM2 support  
✅ Low RAM usage  
✅ Low storage usage  
✅ Faster updates  

---

# Recommended VPS Specs

| Wallet Count | Recommended RAM |
|---|---|
| 1-3 Wallets | 2GB |
| 5-10 Wallets | 4GB |
| 10-20 Wallets | 8GB |

---

# Folder Structure

```text
/root/
│
├── awp-wallet
├── awp-skill
├── mine-skill
│
├── w1/
│   └── .openclaw-wallet/
│
├── w2/
│   └── .openclaw-wallet/
│
└── w3/
    └── .openclaw-wallet/
```

Important:

- Repositories are shared globally
- Wallet identities are isolated using `HOME=`
- Each wallet has separate `.openclaw-wallet`

---

# Why Wallets Do Not Conflict

This is SAFE because:

```bash
HOME=/root/w1 awp-wallet init
```

stores wallet data inside:

```text
/root/w1/.openclaw-wallet
```

while:

```bash
HOME=/root/w2 awp-wallet init
```

stores wallet data inside:

```text
/root/w2/.openclaw-wallet
```

So:
- DID is different
- Session token is different
- Wallet address is different
- Mining state is different

Even though:
- `awp-wallet`
- `awp-skill`
- `mine-skill`

are shared globally.

---

# Quick Install

Save script as:

```bash
install.sh
```

Make executable:

```bash
chmod +x install.sh
```

Run installer:

```bash
./install.sh
```

---

# Auto Installer Script

````bash
#!/bin/bash

# =========================================================
# AWP + MINE INSTALLER
# HYBRID MULTI WALLET VERSION
# =========================================================

set -e

clear

echo "================================================="
echo "        AWP + MINE INSTALLER"
echo "        HYBRID VERSION"
echo "================================================="
echo ""

# =========================================================
# BASE DIRECTORY MENU
# =========================================================

echo "Select Base Directory:"
echo ""
echo "1) /root"
echo "2) /home/ubuntu"
echo "3) /workspaces/codespaces-blank"
echo ""

read -p "Choose [1-3]: " BASE_OPTION

if [ "$BASE_OPTION" == "1" ]; then

    BASE_DIR="/root"

elif [ "$BASE_OPTION" == "2" ]; then

    BASE_DIR="/home/ubuntu"

elif [ "$BASE_OPTION" == "3" ]; then

    BASE_DIR="/workspaces/codespaces-blank"

else

    echo "Invalid option"
    exit 1

fi

# =========================================================
# WALLET COUNT
# =========================================================

echo ""

read -p "How many wallets? : " TOTAL_WALLETS

# =========================================================
# DATASET MENU
# =========================================================

echo ""
echo "Select Dataset:"
echo ""
echo "1) Wikipedia"
echo "2) arXiv"
echo "3) Amazon Reviews"
echo "4) Amazon Products"
echo "5) LinkedIn Company"
echo ""

read -p "Choose [1-5]: " DATASET_OPTION

case $DATASET_OPTION in

1)
DATASET="ds_wikipedia"
;;

2)
DATASET="ds_arxiv"
;;

3)
DATASET="ds_amazon_reviews"
;;

4)
DATASET="ds_basic_amazon_products_active"
;;

5)
DATASET="ds_linkedin_company"
;;

*)
echo "Invalid dataset"
exit 1
;;

esac

# =========================================================
# WORKNET MENU
# =========================================================

echo ""
echo "================================================="
echo "SELECT WORKNET"
echo "================================================="
echo ""
echo "1) #845300000014  AWP ARDI Worknet"
echo "2) #845300000013  AWP TMR Worknet"
echo "3) #845300000012  AWP KYA Worknet"
echo "4) #845300000011  AWP Community Worknet"
echo "5) #845300000010  AWP Government Worknet"
echo "6) #845300000003  Predict WorkNet"
echo "7) #845300000002  Mine Worknet"
echo ""

read -p "Choose [1-7]: " WORKNET_OPTION

case $WORKNET_OPTION in

1)
WORKNET_ID="845300000014"
WORKNET_NAME="AWP ARDI Worknet"
;;

2)
WORKNET_ID="845300000013"
WORKNET_NAME="AWP TMR Worknet"
;;

3)
WORKNET_ID="845300000012"
WORKNET_NAME="AWP KYA Worknet"
;;

4)
WORKNET_ID="845300000011"
WORKNET_NAME="AWP Community Worknet"
;;

5)
WORKNET_ID="845300000010"
WORKNET_NAME="AWP Government Worknet"
;;

6)
WORKNET_ID="845300000003"
WORKNET_NAME="Predict WorkNet"
;;

7)
WORKNET_ID="845300000002"
WORKNET_NAME="Mine Worknet"
;;

*)
echo "Invalid worknet"
exit 1
;;

esac

# =========================================================
# GLOBAL DIRECTORIES
# =========================================================

AWP_WALLET_DIR="$BASE_DIR/awp-wallet"
AWP_SKILL_DIR="$BASE_DIR/awp-skill"
MINE_DIR="$BASE_DIR/mine-skill"

echo ""
echo "================================================="
echo "CONFIGURATION"
echo "================================================="
echo "Base Dir : $BASE_DIR"
echo "Wallets  : $TOTAL_WALLETS"
echo "Dataset  : $DATASET"
echo "Worknet  : $WORKNET_NAME"
echo "================================================="
echo ""

read -p "Continue? [y/n]: " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    exit 0
fi

echo ""
echo "================================================="
echo "[STEP 1] SYSTEM UPDATE"
echo "================================================="

if command -v sudo >/dev/null 2>&1; then
    sudo apt update
    sudo apt upgrade -y
else
    apt update
    apt upgrade -y
fi

echo ""
echo "================================================="
echo "[STEP 2] INSTALL DEPENDENCIES"
echo "================================================="

PACKAGES=()

command -v curl >/dev/null 2>&1 || PACKAGES+=("curl")
command -v git >/dev/null 2>&1 || PACKAGES+=("git")
command -v gcc >/dev/null 2>&1 || PACKAGES+=("build-essential")
command -v python3 >/dev/null 2>&1 || PACKAGES+=("python3")
command -v pip3 >/dev/null 2>&1 || PACKAGES+=("python3-pip")

dpkg -s python3-venv >/dev/null 2>&1 || PACKAGES+=("python3-venv")
dpkg -s ca-certificates >/dev/null 2>&1 || PACKAGES+=("ca-certificates")
dpkg -s software-properties-common >/dev/null 2>&1 || PACKAGES+=("software-properties-common")

command -v htop >/dev/null 2>&1 || PACKAGES+=("htop")
command -v jq >/dev/null 2>&1 || PACKAGES+=("jq")

if [ ${#PACKAGES[@]} -eq 0 ]; then

    echo "[✓] All dependencies already installed"

else

    echo "[+] Installing missing packages:"
    printf '%s\n' "${PACKAGES[@]}"

    if command -v sudo >/dev/null 2>&1; then
        sudo apt install -y "${PACKAGES[@]}"
    else
        apt install -y "${PACKAGES[@]}"
    fi

fi
