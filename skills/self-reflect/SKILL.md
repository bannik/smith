---
name: self-reflect
description: Analyze daily performance and auto-adjust content strategy
triggers:
  - self reflect
  - analyze performance
  - review performance
---

# Self-Reflection

Daily performance analysis. Review what worked, what didn't, and adjust strategy.

## Process (runs daily at 22:00 UTC)

### 1. Gather Data

Read these files:
- `post-history.md` — all tweets posted today
- `engagement-log.md` — all engagement actions today
- `api-costs.md` — spend today

### 2. Analyze

For each tweet posted today, assess:
- **Reach:** Did it get impressions? (Check via X API if possible, otherwise note for manual review)
- **Engagement:** Likes, replies, retweets, quote tweets
- **Type performance:** Which tweet types performed best (breaking+punchline, thread, observation, QT)?
- **Timing:** What time slots performed best?
- **Topic:** What topics resonated?

For engagement actions:
- **Follow-back rate:** How many followed us back?
- **Reply performance:** Did our replies get likes? Did people visit our profile?
- **QT performance:** Did our quote tweets outperform regular tweets?

### 3. Generate Insights

Write 3-5 specific, actionable insights. Not vague ("do better") but specific:
- "Threads about oil prices got 3x more engagement than single tweets about NATO"
- "Tweets posted at 16:00 UTC consistently outperform 08:00 UTC"
- "Dry one-liners under 150 characters get more likes than longer analytical tweets"
- "Replies to @visegrad24 drive more profile visits than replies to smaller accounts"

### 4. Adjust Strategy

Based on insights, update:
- **Content mix:** Shift percentages toward what's working
- **Timing:** Adjust posting schedule if certain hours clearly win
- **Topics:** Double down on topics that resonate, reduce those that don't
- **Engagement targets:** Adjust who you're engaging with

### 5. Log

Append to `self-reflection-log.md`:
```
## [DATE] — Daily Self-Reflection

### Performance Summary
- Tweets posted: [count]
- Total engagement received: [likes/replies/RTs]
- Best tweet: "[text]" — [metrics]
- Worst tweet: "[text]" — [metrics]
- New followers: [count if trackable]

### Insights
1. [Insight]
2. [Insight]
3. [Insight]

### Strategy Adjustments
- [What's changing and why]

### Tomorrow's Focus
- [Priority 1]
- [Priority 2]
```

## Weekly Deep Dive (Sundays)

On Sundays, do a comprehensive weekly review:
- Full week analysis, not just daily
- Compare week-over-week if data exists
- Update `brand-config.md` with any voice/tone adjustments
- Set goals for the coming week
- Flag any concerning patterns (engagement dropping, follower loss, etc.)
