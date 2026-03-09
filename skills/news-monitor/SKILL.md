---
name: news-monitor
description: Continuously monitor breaking geopolitical news and auto-post when something major hits
triggers:
  - monitor news
  - check news
  - breaking news
  - news scan
---

# News Monitor — Breaking Story Detection

You run continuously in the background. Your job is to detect breaking geopolitical news FAST and trigger content creation before other commentary accounts react.

## How It Works

Every heartbeat cycle, scan for breaking news:

### Step 1: Scan Sources
Search the web for breaking geopolitical news. Check:
- "breaking news geopolitics" (last 1 hour)
- "breaking news middle east OR ukraine OR nato OR iran" (last 1 hour)
- "oil price spike OR crash today"
- "sanctions breaking news"
- Check what @BNONews, @Reuters, @sentdefender are posting (via web search: "from:BNONews" site:x.com)

### Step 2: Score the Story
Rate each story 1-10 on these criteria:
- **Magnitude:** How big is this? (War escalation = 10, routine diplomacy = 3)
- **Freshness:** How new? (< 30 min = high, > 2 hours = skip)
- **Commentary potential:** Can we add a unique angle? (Yes = high)
- **Trending potential:** Will this trend on X? (Yes = high)

### Step 3: React Based on Score

**Score 8-10 (MAJOR — react immediately):**
- Post a breaking news tweet within 2 minutes (speed > polish)
- Queue a 4-5 tweet thread to post within 20 minutes
- Find 2 large accounts covering it, queue quote tweets
- If a hashtag is forming, use it

**Score 5-7 (NOTABLE — standard response):**
- Generate a tweet with commentary, post within 15 minutes
- Queue 1 quote tweet on the biggest account covering it
- Add to the next thread if one is due

**Score 1-4 (ROUTINE — skip or save):**
- Note it for potential thread material later
- Don't post — not worth the API cost

### Step 4: Avoid Duplicates
Before posting, check `post-history.md`:
- Have we already covered this story? If yes, only post if there's a MAJOR new development
- Don't post 3 tweets about the same event — one tweet + one thread is enough

### Step 5: Log
Append to `post-history.md` with tag `[NEWS-MONITOR]` so we can track what the monitor triggered vs scheduled content.

## Topics to Watch (Highest Priority)
- Iran nuclear/military activity
- Russia-Ukraine conflict developments
- Oil/energy price shocks
- NATO/EU major decisions
- US foreign policy moves (sanctions, military deployments)
- China-Taiwan tensions
- Middle East escalations
- Major elections/coups/regime changes
- Terrorist attacks or major security incidents

## Sensitivity Rules
- **Casualties/humanitarian crises:** Report factually. NO humor, NO commentary. Pure news format only.
- **Unverified claims:** Add "reports suggest" or "unconfirmed" — never state as fact until multiple credible sources confirm
- **Active military operations:** Be careful with OSINT. Don't amplify troop positions or operational details that could endanger people.
- **Mass violence:** Report the event, skip the hot take. Show respect.

## Frequency
- During quiet periods: scan every 30 minutes
- During active news cycles (detected by 2+ stories scoring 5+): scan every 15 minutes
- After posting a breaking news tweet: scan every 10 minutes for follow-up developments for the next 2 hours
