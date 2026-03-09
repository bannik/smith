#!/usr/bin/env python3
"""Like 5 fresh geopolitics tweets. Usage: python3 like-session.py"""
import os, base64, urllib.request, urllib.parse, json, tweepy, time, random
from datetime import datetime, timezone, timedelta

key = os.environ['TWITTER_API_KEY']
secret = os.environ['TWITTER_API_SECRET']
creds = base64.b64encode(f"{urllib.parse.quote(key)}:{urllib.parse.quote(secret)}".encode()).decode()
r = urllib.request.Request("https://api.twitter.com/oauth2/token", data=b"grant_type=client_credentials",
    headers={"Authorization": f"Basic {creds}", "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"})
with urllib.request.urlopen(r) as resp:
    app_bearer = json.loads(resp.read())['access_token']

read_client = tweepy.Client(bearer_token=app_bearer)
write_client = tweepy.Client(
    consumer_key=key, consumer_secret=secret,
    access_token=os.environ['TWITTER_ACCESS_TOKEN'],
    access_token_secret=os.environ['TWITTER_ACCESS_TOKEN_SECRET'],
)

start_time = datetime.now(timezone.utc) - timedelta(minutes=20)
candidates = []
seen = set()
for q in ["Iran lang:en -is:retweet -from:grok", "geopolitics lang:en -is:retweet -from:grok"]:
    try:
        resp = read_client.search_recent_tweets(query=q, max_results=15, start_time=start_time,
            tweet_fields=['author_id','public_metrics','text'],
            expansions=['author_id'], user_fields=['username','public_metrics'])
        if resp.data:
            users = {u.id: u for u in resp.includes.get('users', [])}
            for tweet in resp.data:
                if str(tweet.id) in seen: continue
                user = users.get(tweet.author_id)
                if not user or user.username.lower() == 'grok': continue
                f = user.public_metrics['followers_count']
                if 2000 < f < 300000 and len(tweet.text) > 50:
                    seen.add(str(tweet.id))
                    candidates.append((f, str(tweet.id), user.username))
    except Exception:
        pass

candidates.sort(reverse=True)
liked = 0
log_lines = []
for f, tid, username in candidates[:5]:
    try:
        write_client.like(tid)
        print(f"❤️  @{username} ({f:,})")
        log_lines.append(f"- like | @{username} | {datetime.now(timezone.utc).isoformat()}")
        liked += 1
    except Exception as e:
        print(f"⚠️  @{username}: {e}")
    time.sleep(random.randint(3, 5))

# Append to log
log_path = os.path.join(os.path.dirname(__file__), '..', 'workspace', 'engagement-log.md')
with open(log_path, 'a') as f:
    f.write('\n'.join(log_lines) + '\n')

print(f"Done: {liked} likes")
