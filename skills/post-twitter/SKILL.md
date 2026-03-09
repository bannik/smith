---
name: post-twitter
description: Post approved tweets to X/Twitter via API v2
triggers:
  - post tweet
  - publish tweet
  - send tweet
---

# Post to Twitter/X

Post approved content to The Audacity Timeline's X account using the Twitter API v2.

## API Details

**Endpoint:** `POST https://api.twitter.com/2/tweets`

**Authentication:** OAuth 1.0a User Context
- Consumer Key: `$TWITTER_API_KEY`
- Consumer Secret: `$TWITTER_API_SECRET`
- Access Token: `$TWITTER_ACCESS_TOKEN`
- Access Token Secret: `$TWITTER_ACCESS_TOKEN_SECRET`

**Single tweet:**
```json
{ "text": "Your tweet text here" }
```

**Reply to a tweet:**
```json
{
  "text": "Your reply",
  "reply": { "in_reply_to_tweet_id": "TWEET_ID" }
}
```

**Quote tweet:**
```json
{
  "text": "Your commentary",
  "quote_tweet_id": "TWEET_ID"
}
```

## Pre-Post Checklist

1. Tweet is under 280 characters
2. No broken links or malformed mentions
3. Not a duplicate of anything in recent `post-history.md`
4. At least 30 minutes since last post (don't spam the timeline)

## Post-Post Actions

After successful post:
1. Log to `post-history.md`:
   ```
   ## [DATE TIME UTC]
   - Type: [single/reply/QT/thread]
   - Text: "[full tweet text]"
   - URL: https://x.com/TheAudacityTL/status/[tweet_id]
   - Hashtags: [if any]
   ```
2. Update `api-costs.md` with the API call

## Error Handling

- **403 Forbidden:** Check if app permissions are Read+Write. Regenerate access tokens if needed.
- **429 Too Many Requests:** Back off. Wait for the reset time in the response header. Log the rate limit hit.
- **400 Bad Request:** Tweet might be a duplicate or over character limit. Check and adjust.
- **401 Unauthorized:** API keys may have been revoked or are incorrect. Alert via Telegram.
