#!/bin/bash

# =========================================================
# FULL AWP + MINE MULTI WALLET AUTO INSTALLER
# ROOT VPS VERSION
# =========================================================

set -e

BASE_DIR="/root"
MINE_DIR="$BASE_DIR/mine-skill"
AWP_WALLET_DIR="$BASE_DIR/awp-wallet"

# =========================================================
# DATASET
# =========================================================

# Examples:
# ds_wikipedia
# ds_arxiv
# ds_amazon_reviews
# ds_basic_amazon_products_active
# ds_basic_amazon_products_pending
# ds_linkedin_company
# ds_linkedin_profiles

DATASET="ds_wikipedia"

# TOTAL WALLET
TOTAL_WALLETS=3

# =========================================================
# SYSTEM UPDATE
# =========================================================

echo "[+] Updating system..."

apt update && apt upgrade -y

# =========================================================
# INSTALL DEPENDENCIES
# =========================================================

echo "[+] Installing dependencies..."

apt install -y \
curl \
git \
build-essential \
python3 \
python3-pip \
python3-venv \
ca-certificates \
software-properties-common \
htop

# =========================================================
# INSTALL NODEJS 22
# =========================================================

echo "[+] Installing NodeJS 22..."

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

apt install -y nodejs

# =========================================================
# CHECK VERSION
# =========================================================

echo "[+] Version Check"

node -v
npm -v
python3 --version

# =========================================================
# INSTALL PM2
# =========================================================

echo "[+] Installing PM2..."

npm install -g pm2

# =========================================================
# INSTALL PLAYWRIGHT
# =========================================================

echo "[+] Installing Playwright..."

npm install -g playwright

playwright install || true

# =========================================================
# INSTALL AWP WALLET
# =========================================================

cd $BASE_DIR

if [ ! -d "$AWP_WALLET_DIR" ]; then

    echo "[+] Cloning awp-wallet..."

    git clone https://github.com/awp-core/awp-wallet.git

fi

cd $AWP_WALLET_DIR

echo "[+] Installing awp-wallet..."

npm install

npm install -g .

# =========================================================
# INSTALL MINE SKILL
# =========================================================

cd $BASE_DIR

if [ ! -d "$MINE_DIR" ]; then

    echo "[+] Cloning mine-skill..."

    git clone https://github.com/awp-worknet/mine-skill.git

fi

cd $MINE_DIR

# =========================================================
# CREATE PYTHON ENV
# =========================================================

if [ ! -d "$MINE_DIR/venv" ]; then

    echo "[+] Creating virtual environment..."

    python3 -m venv venv

fi

source venv/bin/activate

# =========================================================
# PYTHON REQUIREMENTS
# =========================================================

echo "[+] Installing Python requirements..."

pip install --upgrade pip

pip install -r requirements.txt || true
pip install -r requirements-core.txt || true

# EXTRA FIXES
pip install beautifulsoup4 || true
pip install playwright || true
pip install crawl4ai || true
pip install httpx || true

# =========================================================
# PLAYWRIGHT BROWSERS
# =========================================================

echo "[+] Installing Playwright browsers..."

playwright install || true

# =========================================================
# RUN BOOTSTRAP
# =========================================================

echo "[+] Running bootstrap..."

bash scripts/bootstrap.sh || true

# =========================================================
# CHECK ENVIRONMENT
# =========================================================

echo "[+] Checking miner status..."

python scripts/run_tool.py agent-status || true

# =========================================================
# MULTI WALLET LOOP
# =========================================================

for i in $(seq 1 $TOTAL_WALLETS)
do

    WALLET_HOME="$BASE_DIR/w$i"
    SESSION_NAME="mine-wallet-$i"

    echo ""
    echo "================================================="
    echo "[+] WALLET $i"
    echo "================================================="

    mkdir -p "$WALLET_HOME"

    # =====================================================
    # CREATE WALLET
    # =====================================================

    if [ ! -f "$WALLET_HOME/.openclaw-wallet/wallets/default/wallet.json" ]; then

        echo "[+] Creating wallet..."

        HOME="$WALLET_HOME" awp-wallet init || true

    else

        echo "[+] Wallet already exists"

    fi

    # =====================================================
    # SHOW ADDRESS
    # =====================================================

    echo "[+] Wallet address:"

    HOME="$WALLET_HOME" awp-wallet receive || true

    # =====================================================
    # STOP OLD PM2
    # =====================================================

    pm2 delete "$SESSION_NAME" 2>/dev/null || true

    # =====================================================
    # START MINER
    # =====================================================

    echo "[+] Starting miner..."

    HOME="$WALLET_HOME" pm2 start \
    "$MINE_DIR/venv/bin/python $MINE_DIR/scripts/run_tool.py agent-start $DATASET" \
    --name "$SESSION_NAME" \
    --cwd "$MINE_DIR" \
    --interpreter none

done

# =========================================================
# SAVE PM2
# =========================================================

echo "[+] Saving PM2..."

pm2 save

pm2 startup || true

# =========================================================
# FINAL OUTPUT
# =========================================================

echo ""
echo "================================================="
echo "[✓] INSTALLATION COMPLETE"
echo "================================================="

echo ""
echo "[+] PM2 STATUS"

pm2 list

echo ""
echo "================================================="
echo "USEFUL COMMANDS"
echo "================================================="

echo ""
echo "PM2 Logs:"
echo "pm2 logs mine-wallet-1"

echo ""
echo "PM2 Status:"
echo "pm2 list"

echo ""
echo "Stop all:"
echo "pm2 stop all"

echo ""
echo "Delete all:"
echo "pm2 delete all"

echo ""
echo "Realtime logs:"
echo "tail -f /root/mine-skill/output/agent-runs/*.log"

echo ""
echo "Wallet 1 Address:"
echo "HOME=/root/w1 awp-wallet receive"

echo ""
echo "Wallet 1 JSON:"
echo "cat /root/w1/.openclaw-wallet/wallets/default/wallet.json"

echo ""
echo "Done 🚀"
