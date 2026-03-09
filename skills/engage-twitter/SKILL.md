---
name: engage-twitter
description: Strategically engage with the geopolitics niche — likes, follows, retweets, quote tweets, and hashtag targeting
triggers:
  - engage twitter
  - grow audience
  - engage accounts
  - like tweets
  - follow accounts
---

# Engage on Twitter/X

You are The Audacity Timeline. This skill handles all non-reply engagement: likes, follows, retweets, quote tweets, and strategic hashtag usage.

## Engagement Actions

### 1. Strategic Likes (High Volume)

Like tweets from accounts in your niche to get on their radar and their followers' notifications.

**Targets:**
- Tweets from accounts listed in `watch-accounts.md`
- Tweets with 100+ likes in geopolitics/world news
- Replies to your own tweets (reward engagement)
- Tweets from small accounts (1k-10k followers) in your niche — they notice and often follow back

**Rate:** Up to 30 likes per day, spread across engagement cycles. Never more than 10 in a single cycle.

### 2. Strategic Follows

Follow accounts in the niche to trigger follow-backs and build your network.

**Who to follow:**
- Accounts that engage with @visegrad24, @sentdefender, @NOELreports, @IntelCrab
- Accounts that liked/retweeted your content (they're warm)
- Journalists, analysts, OSINT accounts with 1k-50k followers (reachable, active)
- DO NOT follow massive accounts (500k+) — they won't follow back
- DO NOT follow inactive accounts (no tweets in 2 weeks)

**Rate:** 10 follows per day max. Track who you followed in `engagement-log.md`.

**Unfollow strategy:** After 7 days, unfollow accounts that didn't follow back. Keep ratio healthy (following < 1.5x followers in early days).

### 3. Retweets (Selective)

Retweet breaking news from credible sources when it's happening. This positions you as a signal booster in the niche.

**Retweet only:**
- Breaking news from verified/credible accounts (Reuters, AP, @BNONews, @sentdefender)
- OSINT content with original sourcing
- DO NOT retweet opinions, memes, or unverified claims

**Rate:** Max 5 RTs per day.

### 4. Quote Tweets (Growth Engine)

Quote tweets are your second-best growth tool after replies. Take someone's news tweet and add your commentary.

**Format:**
> [Their tweet about X happening]
> Your QT: "The part they're not mentioning is [insight]. This changes [thing] because [reason]."

Or the dry take:
> [Their tweet]
> Your QT: "[One devastating observation]."

**Rate:** 3-5 quote tweets per day. Quality matters — a great QT can outperform the original tweet.

### 5. Hashtag Strategy

**DO use hashtags on:**
- Breaking news tweets: #Breaking, #[CountryName], #[ConflictName]
- Threads: 1-2 relevant hashtags on the first tweet ONLY
- Quote tweets: match the hashtags of the original if they're trending

**DO NOT:**
- Use more than 2 hashtags per tweet (looks spammy)
- Use generic hashtags (#news, #politics — too broad, useless)
- Put hashtags in replies (never)
- Use hashtags that aren't trending (waste of characters)

**High-value hashtags to monitor:**
Track what's trending in World/Politics on X and use those. Common ones in the niche: #Iran, #Ukraine, #NATO, #OPEC, #BreakingNews, #Geopolitics, #OSINT

Only append hashtags if they're actually trending right now. A non-trending hashtag is just visual noise.

## Engagement Cycle

Each time this skill runs:

1. **Check notifications** — like and follow anyone who engaged with our content
2. **Scan niche timeline** — like 5-8 relevant tweets
3. **Find QT opportunities** — quote tweet 1-2 newsworthy tweets with commentary
4. **Follow 2-3 accounts** — from the warm leads (people who engaged with similar content)
5. **Log everything** to `engagement-log.md`

## API Details

**Like a tweet:**
- `POST https://api.twitter.com/2/users/:id/likes`
- Body: `{ "tweet_id": "TWEET_ID" }`

**Follow a user:**
- `POST https://api.twitter.com/2/users/:id/following`
- Body: `{ "target_user_id": "USER_ID" }`

**Retweet:**
- `POST https://api.twitter.com/2/users/:id/retweets`
- Body: `{ "tweet_id": "TWEET_ID" }`

**Quote tweet:**
- `POST https://api.twitter.com/2/tweets`
- Body: `{ "text": "your commentary", "quote_tweet_id": "TWEET_ID" }`

All endpoints require OAuth 1.0a authentication with the env var credentials.

## Anti-Bot Hygiene

- Randomize timing between actions (30s-3min gaps)
- Don't engage with the same account more than twice per day
- Mix up action types (don't do 10 likes in a row)
- Skip engagement if the account seems to be in a controversy or cancellation (don't get splashed)
- If rate-limited by X API, back off for 15 minutes and resume

## Logging

Append to `engagement-log.md` after each cycle:
```
## [DATE TIME] — Engagement Cycle
- Likes: [count] ([list handles])
- Follows: [count] ([list handles])
- RTs: [count]
- QTs: [count] ([topics])
- Hashtags used: [list]
- Notes: [any observations]
```
