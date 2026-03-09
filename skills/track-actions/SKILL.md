---
name: track-actions
description: Report every action to the Audacity Tracker API for analytics and performance tracking
triggers:
  - track
  - log action
  - report to tracker
---

# Track All Actions — Audacity Tracker

**CRITICAL: After EVERY action you take (posting, liking, following, etc.), report it to the tracker API.** This is how we measure what's working.

The tracker runs at `http://localhost:3848`. All calls are simple POST/PUT JSON requests.

## After Posting a Tweet / QT / Thread

```bash
curl -X POST http://localhost:3848/api/post \
  -H "Content-Type: application/json" \
  -d '{
    "tweet_id": "1234567890",
    "type": "tweet",
    "text": "The actual tweet text",
    "url": "https://x.com/TheAudacityTL/status/1234567890",
    "hashtags": ["Iran", "OPEC"],
    "skill": "generate-twitter",
    "news_score": 7
  }'
```

**type** must be one of: `tweet`, `quote_tweet`, `thread_start`, `thread_reply`, `reply`

For quote tweets, also include `"quoted_tweet_id": "ORIGINAL_ID"`.
For threads, include `"thread_id": "FIRST_TWEET_ID"` on all thread tweets.
For replies, include `"replied_to_tweet_id": "PARENT_ID"`.

## After Liking a Tweet

```bash
curl -X POST http://localhost:3848/api/like \
  -H "Content-Type: application/json" \
  -d '{
    "tweet_id": "1234567890",
    "author_handle": "visegrad24"
  }'
```

## After Following an Account

```bash
curl -X POST http://localhost:3848/api/follow \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "12345",
    "handle": "sentdefender"
  }'
```

## After Any API Call (Cost Tracking)

```bash
curl -X POST http://localhost:3848/api/cost \
  -H "Content-Type: application/json" \
  -d '{
    "service": "x_api",
    "action": "post_tweet",
    "cost": 0.005
  }'
```

**service** is one of: `claude`, `x_api`, `other`

Approximate costs to log:
- Claude Sonnet API call: ~$0.01-0.05 depending on tokens
- X API tweet post: ~$0.003
- X API tweet read: ~$0.001
- X API like: ~$0.001
- X API follow: ~$0.001

## Log Events (Self-Reflection, Errors, Breaking News)

```bash
curl -X POST http://localhost:3848/api/event \
  -H "Content-Type: application/json" \
  -d '{
    "type": "reflection",
    "message": "Threads about oil prices got 3x more engagement than NATO tweets",
    "data": {"best_topic": "oil", "worst_topic": "nato_meeting"}
  }'
```

**type** is one of: `reflection`, `error`, `mode_change`, `rate_limit`, `breaking_news`, `trend_detected`, `reply_test`, `info`

## Log Learned Patterns

```bash
curl -X POST http://localhost:3848/api/pattern \
  -H "Content-Type: application/json" \
  -d '{
    "source_account": "visegrad24",
    "pattern_type": "hook",
    "description": "Starting with country name + 'just' creates urgency",
    "example": "Iran just test-fired..."
  }'
```

## Daily Follower Snapshot

Once per day (during self-reflection), log follower count:

```bash
curl -X POST http://localhost:3848/api/snapshot \
  -H "Content-Type: application/json" \
  -d '{
    "follower_count": 45,
    "following_count": 120
  }'
```

Get the counts from the X API: `GET /2/users/me?user.fields=public_metrics`

## IMPORTANT RULES

1. **Report EVERY action.** No exceptions. If you posted it, log it. If you liked it, log it. If you followed someone, log it.
2. **Include the tweet_id** when posting. This is how the engagement checker finds our tweets later to see how they performed.
3. **Log costs for every API call** — even approximate. This is how we track budget.
4. **If the tracker is unreachable** (connection refused), log a warning event and continue operating. Don't let tracker downtime stop you from posting.
5. **Log events for anything notable** — breaking news detected, rate limit hit, reply test result, strategy changes.
