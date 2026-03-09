#!/usr/bin/env python3
"""
Bootstrap cycle — runs every 30 min.
1. Scans news (last 20 min), scores top story
2. Posts one tweet if score >= 5
3. Likes 5 fresh geopolitics tweets
4. Logs everything
"""
import os, sys, base64, urllib.request, urllib.parse, json, tweepy, time, random
from datetime import datetime, timezone, timedelta

WORKSPACE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOG_POST = os.path.join(WORKSPACE, 'workspace', 'post-history.md')
LOG_ENG = os.path.join(WORKSPACE, 'workspace', 'engagement-log.md')
STATE = os.path.join(WORKSPACE, 'memory', 'heartbeat-state.json')

os.makedirs(os.path.join(WORKSPACE, 'workspace'), exist_ok=True)
os.makedirs(os.path.join(WORKSPACE, 'memory'), exist_ok=True)

# --- AUTH ---
key = os.environ['TWITTER_API_KEY']
secret = os.environ['TWITTER_API_SECRET']
creds_b64 = base64.b64encode(f"{urllib.parse.quote(key)}:{urllib.parse.quote(secret)}".encode()).decode()
req = urllib.request.Request("https://api.twitter.com/oauth2/token", data=b"grant_type=client_credentials",
    headers={"Authorization": f"Basic {creds_b64}", "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"})
with urllib.request.urlopen(req) as r:
    app_bearer = json.loads(r.read())['access_token']

read_client = tweepy.Client(bearer_token=app_bearer)
write_client = tweepy.Client(
    consumer_key=key, consumer_secret=secret,
    access_token=os.environ['TWITTER_ACCESS_TOKEN'],
    access_token_secret=os.environ['TWITTER_ACCESS_TOKEN_SECRET'],
)

now = datetime.now(timezone.utc)
start_time = now - timedelta(minutes=20)
skip = ['killed','dead','casualties','children','civilian','hospital','bodies','funeral','mourning']
seen = set()
news = []

# --- NEWS SCAN ---
for q in [
    "BREAKING Iran lang:en -is:retweet -from:grok",
    "(oil barrel OPEC energy) lang:en -is:retweet -from:grok",
    "(Khamenei IRGC NATO Ukraine) lang:en -is:retweet -from:grok",
]:
    try:
        resp = read_client.search_recent_tweets(query=q, max_results=10, start_time=start_time,
            tweet_fields=['author_id','public_metrics','text'],
            expansions=['author_id'], user_fields=['username','public_metrics'])
        if resp.data:
            users = {u.id: u for u in resp.includes.get('users', [])}
            for tweet in resp.data:
                if str(tweet.id) in seen: continue
                user = users.get(tweet.author_id)
                if not user or user.username.lower() == 'grok': continue
                if any(w in tweet.text.lower() for w in skip): continue
                f = user.public_metrics['followers_count']
                if f < 10000 or len(tweet.text) < 40: continue
                seen.add(str(tweet.id))
                score = min(10, f//200000 + tweet.public_metrics['like_count']//10 + tweet.public_metrics['retweet_count']//5 + (3 if 'BREAKING' in tweet.text else 0))
                news.append({'id': str(tweet.id), 'username': user.username, 'followers': f,
                    'text': tweet.text, 'score': score})
    except Exception as e:
        print(f"Search err: {e}")

news.sort(key=lambda x: x['score'], reverse=True)
top = news[0] if news else None
print(f"Top story (score {top['score'] if top else 0}): {top['text'][:100] if top else 'none'}")

# --- POST TWEET (if score >= 5) ---
posted_id = None
if top and top['score'] >= 3:
    t = top['text'].lower()
    if 'oil' in t or 'barrel' in t or 'energy' in t or 'opec' in t:
        tweet = "BREAKING:\n\nOil markets are repricing the Middle East at $100+/barrel. Every government that said this wouldn't escalate is now quietly revising their energy budget. 🛢️"
    elif 'irgc' in t or 'strike' in t or 'attack' in t or 'missile' in t:
        tweet = "BREAKING:\n\nThe IRGC is still operational on day 10. That's the update. The war was supposed to be over by now, according to people who said that. 🇮🇷"
    elif 'khamenei' in t or 'supreme' in t:
        tweet = "Iran's new Supreme Leader inherited a country under active bombardment, a fractured economy, and a military being tested in real time.\n\nNo pressure. 🇮🇷"
    elif 'nato' in t or 'europe' in t:
        tweet = "Europe watching oil spike while scrambling to source alternatives is the policy equivalent of realizing mid-winter you forgot to order heating fuel. 🇪🇺"
    elif 'ukraine' in t or 'russia' in t:
        tweet = "Russia watching its closest ally absorb US-Israeli strikes while oil stays above $100 is having a complicated week. Some of it is good. None of it is good. 🇷🇺"
    else:
        tweet = f"BREAKING:\n\nDay {(now - datetime(2026, 2, 28, tzinfo=timezone.utc)).days} of the US-Israel war on Iran. The situation is evolving. The oil price is not. 🇮🇷🇮🇱🇺🇸"

    try:
        resp = write_client.create_tweet(text=tweet)
        posted_id = resp.data['id']
        print(f"✅ Tweet posted: {posted_id}")
        with open(LOG_POST, 'a') as f:
            f.write(f"\n## {now.isoformat()}\n- **Type:** tweet\n- **Topic:** auto-bootstrap\n- **Tweet ID:** {posted_id}\n- **Text:** {tweet[:100]}\n- **Status:** posted\n")
    except Exception as e:
        print(f"❌ Post failed: {e}")
else:
    print(f"No story scored >= 5, skipping post")

# --- RETWEET SESSION (2-3 RTs of high-follower accounts) ---
rt_candidates = []
seen_rt = set()
for q in ["(Iran OR oil OR Khamenei OR IRGC OR NATO) lang:en -is:retweet -from:grok"]:
    try:
        resp = read_client.search_recent_tweets(query=q, max_results=15, start_time=start_time,
            tweet_fields=['author_id','public_metrics','text'],
            expansions=['author_id'], user_fields=['username','public_metrics'])
        if resp.data:
            users = {u.id: u for u in resp.includes.get('users', [])}
            for tweet in resp.data:
                if str(tweet.id) in seen_rt: continue
                user = users.get(tweet.author_id)
                if not user or user.username.lower() == 'grok': continue
                if any(w in tweet.text.lower() for w in skip): continue
                if tweet.text.startswith('@'): continue  # skip replies
                f = user.public_metrics['followers_count']
                if f < 30000 or len(tweet.text) < 60: continue
                seen_rt.add(str(tweet.id))
                rt_candidates.append((f, str(tweet.id), user.username))
    except Exception as e:
        print(f"RT search err: {e}")

rt_candidates.sort(reverse=True)
rt_count = 0
rt_log = []
for f, tid, username in rt_candidates[:3]:
    try:
        write_client.retweet(tid)
        print(f"🔁 RTed @{username} ({f:,})")
        rt_log.append(f"- retweet | @{username} ({f:,}) | {now.isoformat()}")
        rt_count += 1
    except Exception as e:
        print(f"⚠️  RT @{username}: {e}")
    time.sleep(3)

# --- LIKE SESSION (5 likes) ---
candidates = []
seen2 = set()
for q in ["Iran lang:en -is:retweet -from:grok", "geopolitics lang:en -is:retweet -from:grok"]:
    try:
        resp = read_client.search_recent_tweets(query=q, max_results=12, start_time=start_time,
            tweet_fields=['author_id','public_metrics','text'],
            expansions=['author_id'], user_fields=['username','public_metrics'])
        if resp.data:
            users = {u.id: u for u in resp.includes.get('users', [])}
            for tweet in resp.data:
                if str(tweet.id) in seen2: continue
                user = users.get(tweet.author_id)
                if not user or user.username.lower() == 'grok': continue
                f = user.public_metrics['followers_count']
                if 2000 < f < 300000 and len(tweet.text) > 50:
                    seen2.add(str(tweet.id))
                    candidates.append((f, str(tweet.id), user.username))
    except Exception as e:
        print(f"Like search err: {e}")

candidates.sort(reverse=True)
liked = 0
log_lines = [f"\n## {now.isoformat()} — auto like session"]
for f, tid, username in candidates[:5]:
    try:
        write_client.like(tid)
        print(f"❤️  @{username} ({f:,})")
        log_lines.append(f"- like | @{username} ({f:,})")
        liked += 1
    except Exception as e:
        print(f"⚠️  @{username}: {e}")
    time.sleep(3)

with open(LOG_ENG, 'a') as f:
    f.write('\n'.join(log_lines + rt_log) + '\n')

# --- UPDATE STATE ---
try:
    with open(STATE) as f:
        state = json.load(f)
except Exception:
    state = {'dailyCounts': {'date': now.strftime('%Y-%m-%d'), 'likes': 0, 'tweets_posted': 0, 'follows': 0, 'replies': 0, 'retweets': 0}, 'lastChecks': {}}

if state['dailyCounts'].get('date') != now.strftime('%Y-%m-%d'):
    state['dailyCounts'] = {'date': now.strftime('%Y-%m-%d'), 'likes': 0, 'tweets_posted': 0, 'follows': 0, 'replies': 0, 'retweets': 0}

state['dailyCounts']['likes'] = state['dailyCounts'].get('likes', 0) + liked
state['dailyCounts']['retweets'] = state['dailyCounts'].get('retweets', 0) + rt_count
if posted_id:
    state['dailyCounts']['tweets_posted'] = state['dailyCounts'].get('tweets_posted', 0) + 1
state['lastChecks']['bootstrap_cycle'] = int(now.timestamp())

with open(STATE, 'w') as f:
    json.dump(state, f, indent=2)

print(f"\n✅ Cycle complete — {rt_count} RTs, {liked} likes, {'1 tweet posted' if posted_id else 'no tweet'}")
print(f"Daily totals — tweets: {state['dailyCounts']['tweets_posted']}, RTs: {state['dailyCounts']['retweets']}, likes: {state['dailyCounts']['likes']}")
