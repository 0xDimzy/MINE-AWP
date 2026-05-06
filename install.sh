#!/bin/bash

# =========================================================
# AWP + MINE FULL INSTALLER
# MULTI WALLET VERSION
# =========================================================

set -e

clear

echo "================================================="
echo "        AWP + MINE INSTALLER"
echo "================================================="
echo ""

# =========================================================
# BASE DIRECTORY MENU
# =========================================================

echo "Select Base Directory:"
echo ""
echo "1) /root"
echo "2) /home/ubuntu"
echo ""

read -p "Choose [1-2]: " BASE_OPTION

if [ "$BASE_OPTION" == "1" ]; then

    BASE_DIR="/root"

elif [ "$BASE_OPTION" == "2" ]; then

    BASE_DIR="/home/ubuntu"

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
# DIRECTORIES
# =========================================================

AWP_WALLET_DIR="$BASE_DIR/awp-wallet"
AWP_SKILL_DIR="$BASE_DIR/awp-skill"
MINE_DIR="$BASE_DIR/mine-skill"

# =========================================================
# SHOW CONFIG
# =========================================================

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

# =========================================================
# STEP 1 - SYSTEM UPDATE
# =========================================================

echo ""
echo "================================================="
echo "[STEP 1] SYSTEM UPDATE"
echo "================================================="

apt update && apt upgrade -y

# =========================================================
# STEP 2 - INSTALL DEPENDENCIES
# =========================================================

echo ""
echo "================================================="
echo "[STEP 2] INSTALL DEPENDENCIES"
echo "================================================="

apt install -y \
curl \
git \
build-essential \
python3 \
python3-pip \
python3-venv \
ca-certificates \
software-properties-common \
htop \
jq

# =========================================================
# STEP 3 - INSTALL NODEJS
# =========================================================

echo ""
echo "================================================="
echo "[STEP 3] INSTALL NODEJS"
echo "================================================="

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

apt install -y nodejs

echo ""
echo "[+] Version Check"

node -v
npm -v
python3 --version

# =========================================================
# STEP 4 - INSTALL PM2
# =========================================================

echo ""
echo "================================================="
echo "[STEP 4] INSTALL PM2"
echo "================================================="

npm install -g pm2

# =========================================================
# STEP 5 - INSTALL AWP WALLET
# =========================================================

echo ""
echo "================================================="
echo "[STEP 5] INSTALL AWP-WALLET"
echo "================================================="

cd $BASE_DIR

if [ ! -d "$AWP_WALLET_DIR" ]; then

    git clone https://github.com/awp-core/awp-wallet.git

fi

cd $AWP_WALLET_DIR

chmod +x install.sh

./install.sh

# =========================================================
# STEP 6 - INSTALL AWP SKILL
# =========================================================

echo ""
echo "================================================="
echo "[STEP 6] INSTALL AWP-SKILL"
echo "================================================="

cd $BASE_DIR

if [ ! -d "$AWP_SKILL_DIR" ]; then

    git clone https://github.com/awp-core/awp-skill.git

fi

cd $AWP_SKILL_DIR

if [ ! -d "$AWP_SKILL_DIR/venv" ]; then

    python3 -m venv venv

fi

source venv/bin/activate

pip install --upgrade pip

pip install \
web3 \
requests \
websocket-client \
eth-account

# =========================================================
# STEP 7 - INSTALL MINE-SKILL
# =========================================================

echo ""
echo "================================================="
echo "[STEP 7] INSTALL MINE-SKILL"
echo "================================================="

cd $BASE_DIR

if [ ! -d "$MINE_DIR" ]; then

    git clone https://github.com/awp-worknet/mine-skill.git

fi

cd $MINE_DIR

if [ ! -d "$MINE_DIR/venv" ]; then

    python3 -m venv venv

fi

source venv/bin/activate

pip install --upgrade pip

pip install -r requirements-browser.txt -i https://pypi.org/simple || true
pip install -r requirements-core.txt -i https://pypi.org/simple || true

chmod +x scripts/bootstrap.sh

./scripts/bootstrap.sh || true

# =========================================================
# WALLET LOOP
# =========================================================

for i in $(seq 1 $TOTAL_WALLETS)
do

    echo ""
    echo "================================================="
    echo "[WALLET $i]"
    echo "================================================="

    WALLET_HOME="$BASE_DIR/w$i"

    mkdir -p "$WALLET_HOME"

    # =====================================================
    # CREATE WALLET
    # =====================================================

    echo ""
    echo "[+] Creating Wallet"

    HOME="$WALLET_HOME" awp-wallet init || true

    # =====================================================
    # GET ADDRESS
    # =====================================================

    echo ""
    echo "[+] Wallet Address"

    HOME="$WALLET_HOME" awp-wallet receive || true

    ADDRESS=$(HOME="$WALLET_HOME" awp-wallet receive | jq -r '.eoaAddress')

    # =====================================================
    # UNLOCK TOKEN
    # =====================================================

    echo ""
    echo "[+] Unlock Session"

    TOKEN=$(HOME="$WALLET_HOME" awp-wallet unlock | jq -r '.sessionToken')

    echo "$TOKEN"

    # =====================================================
    # AWP ONBOARDING
    # =====================================================

    echo ""
    echo "================================================="
    echo "[+] AWP ONBOARDING"
    echo "================================================="

    cd "$AWP_SKILL_DIR/scripts"

    HOME="$WALLET_HOME" python3 relay-start.py \
    --token "$TOKEN" \
    --mode principal || true

    HOME="$WALLET_HOME" python3 relay-onboard.py || true

    HOME="$WALLET_HOME" python3 onchain-onboard.py || true

    HOME="$WALLET_HOME" python3 preflight.py \
    --address "$ADDRESS" || true

    HOME="$WALLET_HOME" python3 query-worknet.py \
    --worknet "$WORKNET_ID" || true

    HOME="$WALLET_HOME" python3 query-status.py \
    --token "$TOKEN" || true

    HOME="$WALLET_HOME" python3 relay-register-worknet.py \
    --worknet "$WORKNET_ID" || true

    HOME="$WALLET_HOME" python3 onchain-register.py || true

    # =====================================================
    # DOCTOR CHECK
    # =====================================================

    echo ""
    echo "================================================="
    echo "[+] DOCTOR CHECK"
    echo "================================================="

    cd "$MINE_DIR"

    HOME="$WALLET_HOME" python3 scripts/run_tool.py doctor || true

    # =====================================================
    # START MINER
    # =====================================================

    echo ""
    echo "================================================="
    echo "[+] START MINER"
    echo "================================================="

    ATTEMPT=1

    while true
    do

        echo ""
        echo "[Attempt $ATTEMPT]"

        OUTPUT=$(HOME="$WALLET_HOME" python3 scripts/run_tool.py agent-start $DATASET 2>&1 || true)

        echo "$OUTPUT"

        if echo "$OUTPUT" | grep -q '"state": "running"'; then

            echo ""
            echo "[✓] Mining Started Successfully"

            break

        fi

        echo ""
        echo "[!] Failed / Timeout"
        echo "[!] Retrying in 15 seconds..."

        sleep 15

        ATTEMPT=$((ATTEMPT+1))

    done

    # =====================================================
    # STATUS
    # =====================================================

    echo ""
    echo "================================================="
    echo "[+] MINER STATUS"
    echo "================================================="

    HOME="$WALLET_HOME" python3 scripts/run_tool.py agent-control status || true

    echo ""
    echo "[+] Wallet Folder"
    echo "$WALLET_HOME"

    echo ""
    echo "[✓] Wallet $i Completed"

done

# =========================================================
# FINAL
# =========================================================

echo ""
echo "================================================="
echo "[✓] ALL INSTALLATION COMPLETE"
echo "================================================="

echo ""
echo "Wallet Locations"

for i in $(seq 1 $TOTAL_WALLETS)
do
    echo "$BASE_DIR/w$i"
done

echo ""
echo "Realtime Logs:"
echo "tail -f $MINE_DIR/output/agent-runs/*.log"

echo ""
echo "Check Miner Status:"
echo "HOME=$BASE_DIR/w1 python3 scripts/run_tool.py agent-control status"

echo ""
echo "Stop Miner:"
echo "HOME=$BASE_DIR/w1 python3 scripts/run_tool.py agent-control stop"

echo ""
echo "Wallet JSON:"
echo "cat $BASE_DIR/w1/.openclaw-wallet/wallets/default/wallet.json"

echo ""
echo "Done 🚀"
