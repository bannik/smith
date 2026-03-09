#!/bin/bash
# The Audacity Timeline — OpenClaw Startup Script

set -e

echo "============================================"
echo "  The Audacity Timeline — Agent Launcher"
echo "  News. Commentary. Mostly disbelief."
echo "============================================"
echo ""

# Detect OS for sed compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE="sed -i ''"
else
  SED_INPLACE="sed -i"
fi

# Check prerequisites
echo "[1/5] Checking prerequisites..."

if ! command -v npx &> /dev/null; then
  echo "ERROR: Node.js/npm not found. Install from https://nodejs.org"
  exit 1
fi

if ! npx openclaw --version &> /dev/null 2>&1; then
  echo "ERROR: OpenClaw not found. Install with: npm install -g openclaw"
  exit 1
fi

echo "  ✓ Node.js found"
echo "  ✓ OpenClaw found"

# Check workspace
echo ""
echo "[2/5] Checking workspace..."

WORKSPACE="$HOME/the-audacity-timeline"
if [ ! -d "$WORKSPACE" ]; then
  echo "ERROR: Workspace not found at $WORKSPACE"
  echo "  Copy the the-audacity-timeline folder to your home directory first."
  exit 1
fi

if [ ! -d "$WORKSPACE/skills" ]; then
  echo "ERROR: Skills directory not found at $WORKSPACE/skills"
  exit 1
fi

SKILL_COUNT=$(find "$WORKSPACE/skills" -name "SKILL.md" | wc -l | tr -d ' ')
echo "  ✓ Workspace found: $WORKSPACE"
echo "  ✓ Skills loaded: $SKILL_COUNT"

# Install config
echo ""
echo "[3/5] Installing config..."

OPENCLAW_DIR="$HOME/.openclaw"
mkdir -p "$OPENCLAW_DIR"

if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
  echo "  ⚠ Existing openclaw.json found — backing up to openclaw.json.bak"
  cp "$OPENCLAW_DIR/openclaw.json" "$OPENCLAW_DIR/openclaw.json.bak"
fi

cp "$WORKSPACE/openclaw.json" "$OPENCLAW_DIR/openclaw.json"
echo "  ✓ Config installed"

# Check API keys
echo ""
echo "[4/5] Checking API keys..."

ENV_FILE="$OPENCLAW_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  echo "  Copy .env.example to $ENV_FILE and fill in your keys."
  exit 1
fi

MISSING_KEYS=0
for KEY in ANTHROPIC_API_KEY TWITTER_API_KEY TWITTER_API_SECRET TWITTER_ACCESS_TOKEN TWITTER_ACCESS_TOKEN_SECRET TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID; do
  if ! grep -q "^${KEY}=" "$ENV_FILE" || grep -q "^${KEY}=$" "$ENV_FILE" || grep -q "^${KEY}=your_" "$ENV_FILE" || grep -q "^${KEY}=sk-ant-\.\.\." "$ENV_FILE"; then
    echo "  ✗ Missing: $KEY"
    MISSING_KEYS=1
  else
    echo "  ✓ $KEY"
  fi
done

if [ "$MISSING_KEYS" -eq 1 ]; then
  echo ""
  echo "WARNING: Some API keys are missing. The agent may not function fully."
  echo "  Edit $ENV_FILE to add missing keys."
  read -p "  Continue anyway? (y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Launch
echo ""
echo "[5/5] Launching agent..."
echo ""
echo "  Mode options:"
echo "    1) Full auto (recommended — agent runs on heartbeat schedule)"
echo "    2) Chat mode (interactive — talk to the agent via terminal)"
echo "    3) Single run (generate + post one tweet, then exit)"
echo "    4) Dry run (generate content but don't post)"
echo ""
read -p "  Select mode [1-4]: " MODE

case $MODE in
  1)
    echo ""
    echo "  🚀 Launching in full auto mode..."
    echo "  The agent will post, engage, and self-reflect on schedule."
    echo "  Press Ctrl+C to stop."
    echo ""
    npx openclaw start --workspace "$WORKSPACE"
    ;;
  2)
    echo ""
    echo "  💬 Launching in chat mode..."
    echo ""
    npx openclaw chat --workspace "$WORKSPACE"
    ;;
  3)
    echo ""
    echo "  📝 Single run — generating and posting one tweet..."
    echo ""
    npx openclaw run --workspace "$WORKSPACE" --skill generate-twitter
    ;;
  4)
    echo ""
    echo "  🧪 Dry run — generating content without posting..."
    echo ""
    npx openclaw run --workspace "$WORKSPACE" --skill generate-twitter --dry-run
    ;;
  *)
    echo "  Invalid selection. Launching in full auto mode..."
    npx openclaw start --workspace "$WORKSPACE"
    ;;
esac
