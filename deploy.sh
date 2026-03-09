#!/bin/bash
# ═══════════════════════════════════════════════════════
#  The Audacity Timeline — Hetzner Initial Setup
#  Run ONCE on a fresh server: ssh root@YOUR_SERVER 'bash -s' < deploy.sh
#  After this, GitHub Actions handles all future deploys.
# ═══════════════════════════════════════════════════════
set -euo pipefail

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  The Audacity Timeline — Server Setup        ║"
echo "  ║  News. Commentary. Mostly disbelief.         ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""

# ── 1. System updates ──
echo "[1/7] Updating system..."
apt update && apt upgrade -y

# ── 2. Install Node.js 22 LTS ──
echo "[2/7] Installing Node.js 22..."
if ! command -v node &>/dev/null || [[ "$(node -v)" != v22* ]]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt install -y nodejs
fi
echo "  Node $(node -v) / npm $(npm -v)"

# ── 3. Install OpenClaw ──
echo "[3/7] Installing OpenClaw..."
npm install -g openclaw
echo "  OpenClaw installed"

# ── 4. Create agent user ──
echo "[4/7] Creating agent user..."
if ! id "agent" &>/dev/null; then
  useradd -m -s /bin/bash agent
  echo "  User 'agent' created"
else
  echo "  User 'agent' exists"
fi

# Setup SSH for deploy user (GitHub Actions will use this)
mkdir -p /home/agent/.ssh
cp ~/.ssh/authorized_keys /home/agent/.ssh/ 2>/dev/null || true
chown -R agent:agent /home/agent/.ssh
chmod 700 /home/agent/.ssh
chmod 600 /home/agent/.ssh/authorized_keys 2>/dev/null || true

# ── 5. Create workspace + config dirs ──
echo "[5/7] Setting up directories..."
WORKSPACE="/home/agent/the-audacity-timeline"
OPENCLAW_DIR="/home/agent/.openclaw"

sudo -u agent mkdir -p "$WORKSPACE"
sudo -u agent mkdir -p "$OPENCLAW_DIR"

echo "  Workspace: $WORKSPACE"
echo "  Config:    $OPENCLAW_DIR"

# ── 6. Allow agent user to restart services ──
echo "[6/7] Setting up sudoers..."
cat > /etc/sudoers.d/audacity << 'EOF'
agent ALL=(ALL) NOPASSWD: /bin/systemctl restart audacity-agent, /bin/systemctl restart audacity-dashboard, /bin/systemctl status audacity-agent, /bin/systemctl status audacity-dashboard, /bin/systemctl is-active audacity-agent, /bin/systemctl is-active audacity-dashboard, /bin/chown -R agent\:agent /home/agent/the-audacity-timeline
EOF

# ── 7. Install systemd services ──
echo "[7/7] Installing systemd services..."

cat > /etc/systemd/system/audacity-agent.service << 'UNIT'
[Unit]
Description=The Audacity Timeline — OpenClaw Agent
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=agent
Group=agent
WorkingDirectory=/home/agent/the-audacity-timeline
Environment=HOME=/home/agent
Environment=NODE_ENV=production

ExecStart=/usr/bin/openclaw gateway start
ExecStop=/usr/bin/openclaw gateway stop

Restart=always
RestartSec=30

StandardOutput=journal
StandardError=journal
SyslogIdentifier=audacity-agent

NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=/home/agent

[Install]
WantedBy=multi-user.target
UNIT

cat > /etc/systemd/system/audacity-dashboard.service << 'UNIT'
[Unit]
Description=The Audacity Timeline — Dashboard Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=agent
Group=agent
WorkingDirectory=/home/agent/the-audacity-timeline
Environment=HOME=/home/agent
ExecStart=/usr/bin/node /home/agent/the-audacity-timeline/server.js

Restart=always
RestartSec=10

StandardOutput=journal
StandardError=journal
SyslogIdentifier=audacity-dashboard

NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=/home/agent

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable audacity-agent audacity-dashboard

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  Setup complete!                             ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Create .env with your API keys:"
echo "     nano /home/agent/.openclaw/.env"
echo ""
echo "  2. Add these GitHub repo secrets:"
echo "     HETZNER_SSH_KEY    → private SSH key for 'agent' user"
echo "     HETZNER_SERVER_IP  → your server IP"
echo "     HETZNER_USER       → agent"
echo ""
echo "  3. Push to main — GitHub Actions deploys automatically"
echo ""
echo "  Manual commands:"
echo "     systemctl start audacity-agent"
echo "     systemctl start audacity-dashboard"
echo "     journalctl -u audacity-agent -f"
echo ""
