# MineWork Multi Wallet Setup Guide (Hybrid Version)

Optimized hybrid setup for:

- AWP Wallet
- AWP Skill
- Mine Skill
- Multi Wallet Mining
- PM2 Auto Run
- VPS & Codespaces

This version is:
- More lightweight
- Faster
- Lower RAM usage
- Lower storage usage
- Easier to maintain
- Better for large multi wallet setups

---

# Why Use Hybrid Version?

Most people make this mistake:

```text
/root/
 ├── w1/
 │    ├── awp-wallet
 │    ├── awp-skill
 │    └── mine-skill
 │
 ├── w2/
 │    ├── awp-wallet
 │    ├── awp-skill
 │    └── mine-skill
```

This is BAD because:

- Huge storage usage
- Huge RAM usage
- Slow installation
- Slow updates
- Duplicate dependencies
- Duplicate Python environments

If you run:
- 10 wallets
- 20 wallets
- 50 wallets

your VPS becomes very heavy.

---

# Hybrid Structure (Recommended)

Instead, use:

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

This means:

| Shared Globally | Isolated Per Wallet |
|---|---|
| awp-wallet | .openclaw-wallet |
| awp-skill | session token |
| mine-skill | DID |
| python venv | wallet address |
| dependencies | miner identity |

---

# Is This Safe?

YES.

This is the important part:

```bash
HOME=/root/w1
```

Every AWP/OpenClaw command reads wallet identity from:

```text
$HOME/.openclaw-wallet
```

So:

## Wallet 1

```bash
HOME=/root/w1 awp-wallet init
```

creates:

```text
/root/w1/.openclaw-wallet
```

---

## Wallet 2

```bash
HOME=/root/w2 awp-wallet init
```

creates:

```text
/root/w2/.openclaw-wallet
```

---

# Why Wallets Will NOT Conflict

Even though:
- awp-wallet is shared
- awp-skill is shared
- mine-skill is shared

the identities are different because:

| Wallet | HOME | Wallet Storage |
|---|---|---|
| Wallet 1 | /root/w1 | /root/w1/.openclaw-wallet |
| Wallet 2 | /root/w2 | /root/w2/.openclaw-wallet |
| Wallet 3 | /root/w3 | /root/w3/.openclaw-wallet |

This means:
- different DID
- different session token
- different wallet address
- different miner identity
- different registration
- different worknet participation

---

# VERY IMPORTANT

Always run commands using:

```bash
HOME=/root/w1
```

Example:

```bash
HOME=/root/w1 awp-wallet unlock
```

Correct.

---

NEVER run:

```bash
awp-wallet unlock
```

without HOME.

Because it may use:

```text
/root/.openclaw-wallet
```

and wallets may conflict.

---

# Advantages of Hybrid Setup

| Feature | Hybrid Version |
|---|---|
| Lower RAM | ✅ |
| Lower Storage | ✅ |
| Faster Install | ✅ |
| Faster Update | ✅ |
| Easier Maintenance | ✅ |
| Multi Wallet Friendly | ✅ |
| VPS Friendly | ✅ |
| Codespaces Friendly | ✅ |

---

# Recommended VPS Specs

| Wallet Count | Recommended RAM |
|---|---|
| 1-3 Wallets | 2GB |
| 5-10 Wallets | 4GB |
| 10-20 Wallets | 8GB |

---

# Quick Install

Save installer as:

```bash
install.sh
```

Make executable:

```bash
chmod +x install.sh
```

Run:

```bash
./install.sh
```

---

# Wallet Commands

## Create Wallet

### Wallet 1

```bash
mkdir -p /root/w1

HOME=/root/w1 awp-wallet init
```

### Wallet 2

```bash
mkdir -p /root/w2

HOME=/root/w2 awp-wallet init
```

---

# Check Wallet Address

## Wallet 1

```bash
HOME=/root/w1 awp-wallet receive
```

## Wallet 2

```bash
HOME=/root/w2 awp-wallet receive
```

---

# Open Wallet JSON

## Wallet 1

```bash
cat /root/w1/.openclaw-wallet/wallets/wallets.json
```

## Wallet 2

```bash
cat /root/w2/.openclaw-wallet/wallets/wallets.json
```

---

# Backup Wallet

## Wallet 1

```bash
cp -r /root/w1/.openclaw-wallet /root/w1/wallet-backup
```

---

# Unlock Wallet Session

## Wallet 1

```bash
HOME=/root/w1 awp-wallet unlock
```

---

# Start Mining

## Wikipedia

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-start ds_wikipedia
```

## arXiv

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-start ds_arxiv
```

## Amazon Reviews

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-start ds_amazon_reviews
```

## Amazon Products

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-start ds_basic_amazon_products_active
```

---

# Check Miner Status

## Wallet 1

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-control status
```

---

# Pause Miner

## Wallet 1

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-control pause
```

---

# Resume Miner

## Wallet 1

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-control resume
```

---

# Stop Miner

## Wallet 1

```bash
HOME=/root/w1 python3 /root/mine-skill/scripts/run_tool.py agent-control stop
```

---

# Realtime Logs

```bash
tail -f /root/mine-skill/output/agent-runs/*.log
```

---

# PM2 Auto Run

## Wallet 1

```bash
pm2 start "HOME=/root/w1 /root/mine-skill/.venv/bin/python /root/mine-skill/scripts/run_tool.py agent-start ds_wikipedia" --name mine-wallet-1
```

## Wallet 2

```bash
pm2 start "HOME=/root/w2 /root/mine-skill/.venv/bin/python /root/mine-skill/scripts/run_tool.py agent-start ds_wikipedia" --name mine-wallet-2
```

---

# PM2 Commands

## View miners

```bash
pm2 list
```

---

## Logs

```bash
pm2 logs mine-wallet-1
```

---

## Restart miner

```bash
pm2 restart mine-wallet-1
```

---

## Stop miner

```bash
pm2 stop mine-wallet-1
```

---

## Delete miner

```bash
pm2 delete mine-wallet-1
```

---

## Stop all miners

```bash
pm2 stop all
```

---

## Delete all miners

```bash
pm2 delete all
```

---

# Save PM2 Startup

```bash
pm2 save

pm2 startup
```

---

# Useful Commands

## Check running processes

```bash
ps aux | grep mine
```

---

## Kill process

```bash
kill -9 PID
```

---

## Monitor VPS

```bash
htop
```

---

# Common Dataset IDs

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

# Important Notes

- ALWAYS use `HOME=/root/wX`
- 1 HOME = 1 wallet identity
- Never run commands without HOME
- Shared repo is safe
- Shared venv is safe
- Wallets remain isolated
- Bootstrap only needs to run once
- PM2 is recommended for 24/7 uptime
- Wikipedia dataset is the most stable
- LinkedIn datasets may require proxies
- Amazon datasets may timeout sometimes
- Backup `.openclaw-wallet` regularly
