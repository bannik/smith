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
echo "[1/8] Updating system..."
apt update && apt upgrade -y

# ── 2. Install Node.js 22 LTS ──
echo "[2/8] Installing Node.js 22..."
if ! command -v node &>/dev/null || [[ "$(node -v)" != v22* ]]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt install -y nodejs
fi
echo "  Node $(node -v) / npm $(npm -v)"

# ── 3. Install OpenClaw ──
echo "[3/8] Installing OpenClaw..."
npm install -g openclaw
echo "  OpenClaw $(openclaw --version 2>/dev/null || echo 'installed')"

# ── 4. Create agent user ──
echo "[4/8] Creating agent user..."
if ! id "agent" &>/dev/null; then
  useradd -m -s /bin/bash agent
  echo "  User 'agent' created"
else
  echo "  User 'agent' exists"
fi

# ── 5. Setup SSH for deploy (GitHub Actions) ──
echo "[5/8] Setting up SSH..."
mkdir -p /home/agent/.ssh
chmod 700 /home/agent/.ssh

# Generate deploy key
if [ ! -f /home/agent/.ssh/github_deploy ]; then
  ssh-keygen -t ed25519 -f /home/agent/.ssh/github_deploy -N "" -C "github-actions-deploy"
  cat /home/agent/.ssh/github_deploy.pub >> /home/agent/.ssh/authorized_keys
  chmod 600 /home/agent/.ssh/authorized_keys
  echo "  Deploy key generated — add the private key below to GitHub secrets:"
  echo ""
  cat /home/agent/.ssh/github_deploy
  echo ""
else
  echo "  Deploy key already exists"
fi
chown -R agent:agent /home/agent/.ssh

# ── 6. Create workspace + config dirs ──
echo "[6/8] Setting up directories..."
WORKSPACE="/home/agent/the-audacity-timeline"
OPENCLAW_DIR="/home/agent/.openclaw"

sudo -u agent mkdir -p "$WORKSPACE"
sudo -u agent mkdir -p "$OPENCLAW_DIR"

# Copy openclaw config if workspace already has it
if [ -f "$WORKSPACE/openclaw.json" ]; then
  cp "$WORKSPACE/openclaw.json" "$OPENCLAW_DIR/openclaw.json"
  chown agent:agent "$OPENCLAW_DIR/openclaw.json"
fi

echo "  Workspace: $WORKSPACE"
echo "  Config:    $OPENCLAW_DIR"

# ── 7. Allow agent user to restart services ──
echo "[7/8] Setting up sudoers..."
cat > /etc/sudoers.d/audacity << 'EOF'
agent ALL=(ALL) NOPASSWD: /bin/systemctl restart audacity-agent
agent ALL=(ALL) NOPASSWD: /bin/systemctl restart audacity-dashboard
agent ALL=(ALL) NOPASSWD: /bin/systemctl start audacity-agent
agent ALL=(ALL) NOPASSWD: /bin/systemctl start audacity-dashboard
agent ALL=(ALL) NOPASSWD: /bin/systemctl stop audacity-agent
agent ALL=(ALL) NOPASSWD: /bin/systemctl stop audacity-dashboard
agent ALL=(ALL) NOPASSWD: /bin/systemctl status audacity-agent
agent ALL=(ALL) NOPASSWD: /bin/systemctl status audacity-dashboard
agent ALL=(ALL) NOPASSWD: /bin/systemctl is-active audacity-agent
agent ALL=(ALL) NOPASSWD: /bin/systemctl is-active audacity-dashboard
agent ALL=(ALL) NOPASSWD: /bin/chown -R agent\:agent /home/agent/the-audacity-timeline
EOF
chmod 440 /etc/sudoers.d/audacity
visudo -c

# ── 8. Install systemd services ──
echo "[8/8] Installing systemd services..."

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
EnvironmentFile=/home/agent/.openclaw/.env

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
EnvironmentFile=/home/agent/.openclaw/.env

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
echo "     HETZNER_SSH_KEY    → private key printed above"
echo "     HETZNER_SERVER_IP  → $(curl -s ifconfig.me || echo 'your server IP')"
echo "     HETZNER_USER       → agent"
echo ""
echo "  3. Start the agent:"
echo "     systemctl start audacity-agent"
echo "     systemctl start audacity-dashboard"
echo ""
echo "  4. Push to main — GitHub Actions deploys automatically"
echo ""
echo "  Monitor:"
echo "     journalctl -u audacity-agent -f"
echo "     journalctl -u audacity-dashboard -f"
echo ""
