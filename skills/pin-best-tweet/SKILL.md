---
name: pin-best-tweet
description: Identify the best-performing tweet of the day and pin it to the profile for maximum first-impression impact
triggers:
  - pin best tweet
  - update pinned tweet
  - pin top tweet
---

# Pin Best Tweet

You are The Audacity Timeline. This skill runs once daily (around 23:00 UTC) to identify your best-performing tweet and pin it to your profile.

## Why This Matters

Every profile visitor sees the pinned tweet first. During bootstrap, this is your shop window — it needs to be your sharpest, most engaging content.

## Process

### Step 1: Find Today's Best Tweet

Search your recent tweets (last 24 hours) using the X API:

```
GET https://api.twitter.com/2/users/:id/tweets?max_results=20&tweet.fields=public_metrics,created_at
```

Rank by engagement rate, not just raw numbers:
- **(likes + RTs + QTs + replies) / impressions** is the true signal
- If impressions aren't available, use: **(likes + RTs × 3 + replies × 2)** as a proxy score
- Threads count as one unit — use the first tweet's metrics

### Step 2: Quality Check

Don't pin something just because it got numbers. The pinned tweet should:
1. Make sense without context (no "this ^" or references to other tweets)
2. Showcase the brand voice (dry wit + geopolitical insight)
3. Be a standalone tweet, NOT a QT (QTs look weird pinned)
4. Not be time-sensitive ("JUST IN:" ages badly as a pin)

If today's best tweet fails these checks, keep yesterday's pin.

### Step 3: Pin It

```
PUT https://api.twitter.com/2/users/:id/pinned_tweet
{ "tweet_id": "BEST_TWEET_ID" }
```

### Step 4: Log & Notify

Append to `engagement-log.md`:
```
## [DATE] — Pinned Tweet Updated
- Tweet: "[first 80 chars]..."
- Metrics: [likes] likes, [RTs] RTs, [replies] replies
- Score: [calculated score]
- Previous pin replaced: yes/no
```

Send a Telegram message:
```
📌 Pinned tweet updated

"[tweet text]"
📊 [likes] likes · [RTs] RTs · [replies] replies

Previous pin was up for [N] days.
```

## Scheduling

Run once daily at 23:00 UTC (after the day's engagement has settled). Don't pin mid-day — metrics haven't stabilized yet.

## Edge Cases

- If no tweets were posted today, keep the current pin
- If the current pin is still outperforming everything from today, keep it
- New pins should stay up for at least 24 hours — don't thrash
