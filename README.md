# MineWork Multi Wallet Setup Guide

Full VPS setup for:

* AWP Wallet
* Mine Skill
* Multi Wallet Mining
* PM2 Auto Run
* Wallet Backup
* Logs & Monitoring

---

# Requirements

* Ubuntu VPS
* Root access
* 2GB+ RAM recommended

---

# 1. System Update

```bash
apt update && apt upgrade -y
```

---

# 2. Install Dependencies

```bash
apt install -y \
curl \
git \
build-essential \
python3 \
python3-pip \
python3-venv \
ca-certificates \
software-properties-common
```

---

# 3. Install NodeJS 22

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

apt install -y nodejs
```

Check version:

```bash
node -v
npm -v
```

---

# 4. Install PM2

```bash
npm install -g pm2
```

---

# 5. Install AWP Wallet

```bash
cd /root

git clone https://github.com/awp-core/awp-wallet.git

cd awp-wallet

npm install

npm install -g .
```

Test:

```bash
awp-wallet --help
```

---

# 6. Install Mine Skill

```bash
cd /root

git clone https://github.com/awp-worknet/mine-skill.git

cd mine-skill
```

---

# 7. Create Python Environment

```bash
python3 -m venv venv

source venv/bin/activate
```

---

# 8. Install Python Requirements

```bash
pip install --upgrade pip

pip install -r requirements.txt
```

If needed:

```bash
pip install -r requirements-core.txt
```

---

# 9. Run Bootstrap

```bash
bash scripts/bootstrap.sh
```

---

# 10. Check Miner Status

```bash
python scripts/run_tool.py agent-status
```

Expected:

```json
{
  "ready": true
}
```

---

# 11. Create Multi Wallets

## Wallet 1

```bash
mkdir -p /root/w1

HOME=/root/w1 awp-wallet init
```

## Wallet 2

```bash
mkdir -p /root/w2

HOME=/root/w2 awp-wallet init
```

## Wallet 3

```bash
mkdir -p /root/w3

HOME=/root/w3 awp-wallet init
```

---

# 12. Check Wallet Address

## Wallet 1

```bash
HOME=/root/w1 awp-wallet receive
```

## Wallet 2

```bash
HOME=/root/w2 awp-wallet receive
```

## Wallet 3

```bash
HOME=/root/w3 awp-wallet receive
```

---

# 13. Wallet File Locations

## Wallet 1

```text
/root/w1/.openclaw-wallet/
```

## Wallet 2

```text
/root/w2/.openclaw-wallet/
```

## Wallet 3

```text
/root/w3/.openclaw-wallet/
```

---

# 14. View Wallet JSON

```bash
cat /root/w1/.openclaw-wallet/wallets/default/wallet.json
```

---

# 15. Backup Wallet

```bash
cp -r /root/w1/.openclaw-wallet /root/w1/wallet-backup
```

---

# 16. Start Mining

## Wikipedia

```bash
HOME=/root/w1 python scripts/run_tool.py agent-start ds_wikipedia
```

## arXiv

```bash
HOME=/root/w1 python scripts/run_tool.py agent-start ds_arxiv
```

## Amazon Reviews

```bash
HOME=/root/w1 python scripts/run_tool.py agent-start ds_amazon_reviews
```

## Amazon Products

```bash
HOME=/root/w1 python scripts/run_tool.py agent-start ds_basic_amazon_products_active
```

---

# 17. Mining Status

```bash
HOME=/root/w1 python scripts/run_tool.py agent-control status
```

---

# 18. Pause Mining

```bash
HOME=/root/w1 python scripts/run_tool.py agent-control pause
```

---

# 19. Resume Mining

```bash
HOME=/root/w1 python scripts/run_tool.py agent-control resume
```

---

# 20. Stop Mining

```bash
HOME=/root/w1 python scripts/run_tool.py agent-control stop
```

---

# 21. Start Miner with PM2

## Wallet 1

```bash
pm2 start "HOME=/root/w1 /root/mine-skill/venv/bin/python /root/mine-skill/scripts/run_tool.py agent-start ds_wikipedia" --name mine-wallet-1
```

## Wallet 2

```bash
pm2 start "HOME=/root/w2 /root/mine-skill/venv/bin/python /root/mine-skill/scripts/run_tool.py agent-start ds_wikipedia" --name mine-wallet-2
```

## Wallet 3

```bash
pm2 start "HOME=/root/w3 /root/mine-skill/venv/bin/python /root/mine-skill/scripts/run_tool.py agent-start ds_wikipedia" --name mine-wallet-3
```

---

# 22. PM2 Commands

## View miners

```bash
pm2 list
```

## Logs

```bash
pm2 logs mine-wallet-1
```

## Restart miner

```bash
pm2 restart mine-wallet-1
```

## Stop miner

```bash
pm2 stop mine-wallet-1
```

## Delete miner

```bash
pm2 delete mine-wallet-1
```

## Stop all

```bash
pm2 stop all
```

---

# 23. Save PM2 Startup

```bash
pm2 save

pm2 startup
```

---

# 24. Realtime Logs

```bash
tail -f /root/mine-skill/output/agent-runs/*.log
```

---

# 25. Common Dataset IDs

```text
ds_wikipedia
ds_arxiv
ds_amazon_reviews
ds_basic_amazon_products_active
ds_basic_amazon_products_pending
ds_linkedin_company
ds_linkedin_profiles
```

---

# 26. Reward Multipliers

| Dataset           | Weight |
| ----------------- | ------ |
| Wikipedia         | 1x     |
| arXiv             | 1x     |
| LinkedIn Company  | 5x     |
| LinkedIn Posts    | 5x     |
| Amazon Products   | 8x     |
| Amazon Reviews    | 8x     |
| LinkedIn Profiles | 12x    |

---

# 27. Useful Commands

## Check running processes

```bash
ps aux | grep mine
```

## Kill process

```bash
kill -9 PID
```

## Monitor VPS

```bash
htop
```

Install htop:

```bash
apt install htop -y
```

---

# 28. Update Mine Skill

```bash
cd /root/mine-skill

git pull
```

---

# 29. Update AWP Wallet

```bash
cd /root/awp-wallet

git pull

npm install

npm install -g .
```

---

# 30. Notes

* 1 HOME = 1 wallet
* Backup wallet files regularly
* Wikipedia is the most stable dataset
* LinkedIn datasets may require proxies
* Amazon datasets can timeout sometimes
* PM2 is recommended for 24/7 uptime
