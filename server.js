const http = require('http');
const https = require('https');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const PORT = 3847;
const WORKSPACE = path.join(require('os').homedir(), 'the-audacity-timeline');
const ENV_PATH = path.join(require('os').homedir(), '.openclaw', '.env');

// ── OAuth 2.0 PKCE helpers ──
let pkceState = {};

function generatePKCE() {
  const verifier = crypto.randomBytes(32).toString('base64url');
  const challenge = crypto.createHash('sha256').update(verifier).digest('base64url');
  const state = crypto.randomBytes(16).toString('hex');
  return { verifier, challenge, state };
}

function getEnvValue(key) {
  try {
    const raw = fs.readFileSync(ENV_PATH, 'utf8');
    const match = raw.match(new RegExp(`^${key}=(.+)$`, 'm'));
    return match ? match[1].trim() : '';
  } catch { return ''; }
}

function appendEnv(key, value) {
  try {
    let raw = fs.readFileSync(ENV_PATH, 'utf8');
    const regex = new RegExp(`^${key}=.*$`, 'm');
    if (regex.test(raw)) {
      raw = raw.replace(regex, `${key}=${value}`);
    } else {
      raw = raw.trimEnd() + `\n${key}=${value}\n`;
    }
    fs.writeFileSync(ENV_PATH, raw);
  } catch (e) { console.error('Failed to write env:', e.message); }
}

function httpsPost(url, body, headers) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const req = https.request({
      hostname: parsed.hostname,
      path: parsed.pathname + parsed.search,
      method: 'POST',
      headers
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch { reject(new Error(data)); }
      });
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

// ── Read a workspace file safely ──
function readFile(name) {
  try { return fs.readFileSync(path.join(WORKSPACE, name), 'utf8'); }
  catch { return ''; }
}

// ── Parse .env file ──
function parseEnv() {
  try {
    const raw = fs.readFileSync(ENV_PATH, 'utf8');
    const keys = {};
    raw.split('\n').forEach(line => {
      const match = line.match(/^([A-Z_]+)=(.+)$/);
      if (match) {
        const val = match[2].trim();
        // Don't send actual values, just whether they're set
        const isPlaceholder = !val || val.startsWith('your_') || val === 'sk-ant-...' || val.length < 5;
        keys[match[1]] = !isPlaceholder;
      }
    });
    return keys;
  } catch { return {}; }
}

// ── Check if openclaw is running ──
function isAgentRunning() {
  try {
    const result = execSync('pgrep -f openclaw', { encoding: 'utf8', timeout: 3000 });
    return result.trim().length > 0;
  } catch { return false; }
}

// ── Parse post-history.md into structured data ──
function parsePostHistory() {
  const raw = readFile('post-history.md');
  const posts = [];
  const blocks = raw.split(/^## /m).filter(b => b.trim());
  for (const block of blocks) {
    const lines = block.split('\n');
    const dateMatch = lines[0]?.match(/(\d{4}-\d{2}-\d{2}|\w+ \d+)/);
    const textMatch = block.match(/Text:\s*"([^"]+)"/);
    const typeMatch = block.match(/Type:\s*(\w+)/);
    const urlMatch = block.match(/URL:\s*(https?:\/\/\S+)/);
    if (dateMatch) {
      posts.push({
        date: dateMatch[1],
        text: textMatch ? textMatch[1] : '',
        type: typeMatch ? typeMatch[1] : 'unknown',
        url: urlMatch ? urlMatch[1] : ''
      });
    }
  }
  return posts;
}

// ── Parse engagement-log.md ──
function parseEngagementLog() {
  const raw = readFile('engagement-log.md');
  const entries = [];
  const blocks = raw.split(/^## /m).filter(b => b.trim() && !b.startsWith('<!--'));
  for (const block of blocks) {
    const lines = block.split('\n');
    const likesMatch = block.match(/Likes:\s*(\d+)/);
    const followsMatch = block.match(/Follows:\s*(\d+)/);
    const rtsMatch = block.match(/RTs:\s*(\d+)/);
    const qtsMatch = block.match(/QTs:\s*(\d+)/);
    const repliesMatch = block.match(/Replies:\s*(\d+)/);
    entries.push({
      header: lines[0]?.trim() || '',
      likes: likesMatch ? parseInt(likesMatch[1]) : 0,
      follows: followsMatch ? parseInt(followsMatch[1]) : 0,
      rts: rtsMatch ? parseInt(rtsMatch[1]) : 0,
      qts: qtsMatch ? parseInt(qtsMatch[1]) : 0,
      replies: repliesMatch ? parseInt(repliesMatch[1]) : 0,
    });
  }
  return entries;
}

// ── Parse self-reflection-log.md ──
function parseReflectionLog() {
  const raw = readFile('self-reflection-log.md');
  const blocks = raw.split(/^## /m).filter(b => b.trim() && !b.startsWith('<!--'));
  if (blocks.length === 0) return null;
  const latest = blocks[blocks.length - 1];
  return latest.trim();
}

// ── Parse api-costs.md ──
function parseCosts() {
  const raw = readFile('api-costs.md');
  const rows = [];
  const lines = raw.split('\n');
  for (const line of lines) {
    const match = line.match(/\|\s*(\S+)\s*\|\s*([^|]+)\s*\|\s*(\d+)\s*\|\s*\$?([\d.]+)\s*\|\s*\$?([\d.]+)\s*\|/);
    if (match && !match[1].includes('Date') && !match[1].includes('-')) {
      rows.push({
        date: match[1],
        service: match[2].trim(),
        calls: parseInt(match[3]),
        cost: parseFloat(match[4]),
        total: parseFloat(match[5])
      });
    }
  }
  return rows;
}

// ── Aggregate daily stats ──
function getDailyStats(posts, engagement) {
  const days = {};
  for (const p of posts) {
    const d = p.date;
    if (!days[d]) days[d] = { tweets: 0, replies: 0, threads: 0 };
    if (p.type === 'reply') days[d].replies++;
    else if (p.type === 'thread') days[d].threads++;
    else days[d].tweets++;
  }
  return days;
}

// ── CORS headers ──
function setCors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Content-Type', 'application/json');
}

// ── Server ──
const server = http.createServer((req, res) => {
  // Serve the dashboard HTML
  if (req.url === '/' || req.url === '/dashboard') {
    res.setHeader('Content-Type', 'text/html');
    try {
      const html = fs.readFileSync(path.join(WORKSPACE, 'dashboard.html'), 'utf8');
      res.end(html);
    } catch {
      res.writeHead(404);
      res.end('dashboard.html not found in workspace');
    }
    return;
  }

  // API endpoints
  if (req.url === '/api/status') {
    setCors(res);
    res.end(JSON.stringify({
      agentRunning: isAgentRunning(),
      envKeys: parseEnv(),
      workspaceExists: fs.existsSync(WORKSPACE),
      skillCount: (() => {
        try {
          return fs.readdirSync(path.join(WORKSPACE, 'skills')).filter(d =>
            fs.existsSync(path.join(WORKSPACE, 'skills', d, 'SKILL.md'))
          ).length;
        } catch { return 0; }
      })()
    }));
    return;
  }

  if (req.url === '/api/posts') {
    setCors(res);
    res.end(JSON.stringify(parsePostHistory()));
    return;
  }

  if (req.url === '/api/engagement') {
    setCors(res);
    res.end(JSON.stringify(parseEngagementLog()));
    return;
  }

  if (req.url === '/api/reflection') {
    setCors(res);
    res.end(JSON.stringify({ latest: parseReflectionLog() }));
    return;
  }

  if (req.url === '/api/costs') {
    setCors(res);
    res.end(JSON.stringify(parseCosts()));
    return;
  }

  if (req.url === '/api/all') {
    setCors(res);
    res.end(JSON.stringify({
      status: {
        agentRunning: isAgentRunning(),
        envKeys: parseEnv(),
        workspaceExists: fs.existsSync(WORKSPACE),
        skillCount: (() => {
          try {
            return fs.readdirSync(path.join(WORKSPACE, 'skills')).filter(d =>
              fs.existsSync(path.join(WORKSPACE, 'skills', d, 'SKILL.md'))
            ).length;
          } catch { return 0; }
        })()
      },
      posts: parsePostHistory(),
      engagement: parseEngagementLog(),
      reflection: parseReflectionLog(),
      costs: parseCosts()
    }));
    return;
  }

  // ── OAuth 2.0 PKCE: Start auth flow ──
  if (req.url === '/auth/twitter') {
    const clientId = getEnvValue('TWITTER_CLIENT_ID');
    if (!clientId) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('TWITTER_CLIENT_ID not set in .env');
      return;
    }
    const pkce = generatePKCE();
    pkceState = pkce;
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: clientId,
      redirect_uri: `http://${req.headers.host}/callback`,
      scope: 'tweet.read tweet.write users.read follows.read follows.write like.read like.write offline.access',
      state: pkce.state,
      code_challenge: pkce.challenge,
      code_challenge_method: 'S256'
    });
    res.writeHead(302, { Location: `https://twitter.com/i/oauth2/authorize?${params}` });
    res.end();
    return;
  }

  // ── OAuth 2.0 PKCE: Handle callback ──
  if (req.url?.startsWith('/callback')) {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const code = url.searchParams.get('code');
    const state = url.searchParams.get('state');
    const error = url.searchParams.get('error');

    if (error) {
      res.writeHead(400, { 'Content-Type': 'text/html' });
      res.end(`<h1>Auth failed</h1><p>${error}</p>`);
      return;
    }

    if (!code || state !== pkceState.state) {
      res.writeHead(400, { 'Content-Type': 'text/html' });
      res.end('<h1>Invalid callback</h1><p>State mismatch or missing code. <a href="/auth/twitter">Try again</a></p>');
      return;
    }

    const clientId = getEnvValue('TWITTER_CLIENT_ID');
    const clientSecret = getEnvValue('TWITTER_CLIENT_SECRET');
    const body = new URLSearchParams({
      code,
      grant_type: 'authorization_code',
      client_id: clientId,
      redirect_uri: `http://${req.headers.host}/callback`,
      code_verifier: pkceState.verifier
    }).toString();

    const authHeader = 'Basic ' + Buffer.from(`${clientId}:${clientSecret}`).toString('base64');

    httpsPost('https://api.twitter.com/2/oauth2/token', body, {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': authHeader
    }).then(tokens => {
      if (tokens.access_token) {
        appendEnv('TWITTER_OAUTH2_ACCESS_TOKEN', tokens.access_token);
        if (tokens.refresh_token) {
          appendEnv('TWITTER_OAUTH2_REFRESH_TOKEN', tokens.refresh_token);
        }
        pkceState = {};
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(`
          <h1>Authorized!</h1>
          <p>OAuth 2.0 tokens saved to .env</p>
          <p>Access token: ${tokens.access_token.substring(0, 20)}...</p>
          ${tokens.refresh_token ? '<p>Refresh token saved (offline.access)</p>' : ''}
          <p>Restart the agent to pick up the new tokens: <code>sudo systemctl restart audacity-agent</code></p>
        `);
      } else {
        res.writeHead(400, { 'Content-Type': 'text/html' });
        res.end(`<h1>Token exchange failed</h1><pre>${JSON.stringify(tokens, null, 2)}</pre>`);
      }
    }).catch(err => {
      res.writeHead(500, { 'Content-Type': 'text/html' });
      res.end(`<h1>Error</h1><pre>${err.message}</pre>`);
    });
    return;
  }

  if (req.method === 'OPTIONS') {
    setCors(res);
    res.writeHead(204);
    res.end();
    return;
  }

  res.writeHead(404);
  res.end('Not found');
});

server.listen(PORT, () => {
  console.log(`\n  ╔══════════════════════════════════════════╗`);
  console.log(`  ║  The Audacity Timeline — Dashboard       ║`);
  console.log(`  ║  http://localhost:${PORT}                   ║`);
  console.log(`  ╚══════════════════════════════════════════╝\n`);
  console.log(`  Reading workspace: ${WORKSPACE}`);
  console.log(`  Reading .env: ${ENV_PATH}`);
  console.log(`  Press Ctrl+C to stop.\n`);
});
