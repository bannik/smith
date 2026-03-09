---
name: bootstrap-growth
description: Growth strategy for new accounts (0-500 followers). Optimizes for what works when replies are restricted.
triggers:
  - bootstrap
  - grow account
  - new account strategy
---

# Bootstrap Growth Mode (0-500 followers)

The account is new. Twitter's anti-spam system restricts cold API replies for new accounts. This skill defines what DOES work right now and how to maximize it.

## What Works Right Now

### 1. QUOTE TWEETS (Your #1 Growth Lever)
Quote tweets are NOT restricted like replies. They work via the regular tweet endpoint. A quote tweet with sharp commentary gets shown to BOTH your followers AND the original poster's audience.

**Process:**
- Every 90 minutes during peak hours (13:00-22:00 UTC), find 1-2 viral tweets in geopolitics
- Add your commentary as a quote tweet
- Target tweets with 1k+ likes from large accounts — the bigger the original, the more eyeballs on your QT

**API call — this is just a regular tweet with a quote_tweet_id:**
```json
POST https://api.twitter.com/2/tweets
{
  "text": "Your commentary here",
  "quote_tweet_id": "ORIGINAL_TWEET_ID"
}
```

**QT formulas that go viral:**
- **The Reframe:** Take the news and present an angle nobody considered
- **The Missing Context:** Add the one fact that changes everything about the story
- **The Deadpan:** One devastating sentence. Nothing more.
- **The Pattern:** "This is the third time this month that [pattern]. At what point do we stop calling it a coincidence?"

### 2. THREADS (Your #2 Growth Lever)
Threads get 3-5x more algorithmic reach than single tweets. For a new account, a great thread is the fastest way to go viral.

Post 2 threads per day instead of 1:
- **Morning thread (08:00-10:00 UTC):** Overnight news recap for the EU audience
- **Afternoon thread (15:00-17:00 UTC):** Day's biggest story for the US+EU overlap

Thread structure that performs:
- Tweet 1: Bold claim or striking fact (this is your billboard)
- Tweet 2-3: Evidence and context
- Tweet 4: The "nobody's talking about this" angle
- Tweet 5: Punchy closer

### 3. TRENDING HASHTAG HIJACKING
When a geopolitical topic is trending, post your take with the trending hashtag. This puts your tweet in front of people who don't follow you yet.

- Check trending topics every hour
- If a geopolitics-related topic is trending, immediately post a tweet with that hashtag
- Keep the tweet under 200 characters + hashtag (short tweets with hashtags perform better in Trending)
- Post within the first 30 minutes of a topic trending for maximum visibility

### 4. HEAVY LIKES (Build Interaction History)
Like 50+ tweets per day from accounts in the niche. This:
- Gets you on their notification feed (they check who liked)
- Builds the "interaction history" that unlocks reply permissions faster
- Costs almost nothing on pay-as-you-go

Target:
- Like every tweet from accounts in watch-accounts.md
- Like tweets from anyone who engages with your content
- Like tweets from mid-tier accounts (5k-50k followers) — they actually notice

### 5. FOLLOW STRATEGICALLY
Follow 15-20 accounts per day (don't exceed — looks spammy):
- Journalists covering geopolitics
- OSINT accounts
- Analysts and commentators
- Anyone who likes/RTs content from watch-accounts.md

### 6. POST VOLUME
During bootstrap, post MORE not less:
- 6-8 single tweets per day (every 2-3 hours)
- 2 threads per day
- 3-5 quote tweets per day
- This gives the algorithm more signals and more chances for something to hit

### 7. RIDE BREAKING NEWS HARD
When something breaks (missile strike, leader statement, oil spike):
- Post within 5 minutes. Speed matters more than polish.
- Follow up with a thread within 30 minutes
- Post 2-3 quote tweets on other accounts' coverage
- This is when new accounts get discovered — everyone is searching the topic

## What Does NOT Work Yet
- Cold replies to tweets from accounts we haven't interacted with (API restricted)
- Replies will unlock naturally as the account ages and builds interaction history
- DO NOT waste API calls attempting replies — they'll 403

## When to Exit Bootstrap Mode
Switch to the full engagement playbook when:
- Account is 3+ weeks old AND
- Has 200+ followers AND
- Replies start working (test with one reply per day)

## Daily Bootstrap Schedule
- 06:00 UTC: Check overnight news, post 1 tweet
- 08:00 UTC: Morning thread (EU audience)
- 10:00 UTC: Post tweet + 2 quote tweets
- 13:00 UTC: Like spree (20 likes) + follow 5 accounts
- 14:00 UTC: Post tweet + check trending hashtags
- 15:00-17:00 UTC: Afternoon thread + 2 quote tweets
- 18:00 UTC: Like spree (15 likes) + post tweet
- 20:00 UTC: Post tweet + quote tweet + follow 5 accounts
- 22:00 UTC: Self-reflect, daily report, like spree (15 likes)
