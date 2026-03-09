---
name: learn-accounts
description: Study reference accounts, extract what's trending, adapt voice and content strategy in real-time
triggers:
  - learn from accounts
  - study accounts
  - analyze accounts
  - what's trending
---

# Learn From Reference Accounts + Trend Detection

This skill does two things: studies reference accounts to improve our voice, and detects what topics/formats are trending RIGHT NOW so we can ride the wave.

## Part 1: Account Study (Every 4 hours)

### Step 1: Scrape What's Working
For each account in `watch-accounts.md`, search the web:
- `"from:visegrad24" site:x.com` (last 24 hours)
- `"from:sentdefender" site:x.com` (last 24 hours)
- etc.

### Step 2: Extract Patterns
For each account's recent content, analyze:

**Content patterns:**
- What topics are they covering right now?
- Which of their tweets got the most engagement in the last 24h?
- What's their tweet-to-thread ratio?
- Are they using images, maps, screenshots?

**Voice patterns:**
- How are they opening their best-performing tweets? Extract the first 10 words.
- What sentence structures recur? (e.g., "[Country] just [did thing]. [Commentary].")
- How long are their top tweets? (Short punchy vs. longer analytical)
- Do they use numbers/stats? How?

**Engagement patterns:**
- What are they quote-tweeting?
- Who are they replying to?
- What time are they most active?

### Step 3: Generate Few-Shot Examples
This is the key step. Take their 3 best tweets from the last 24 hours and **rewrite them in our voice.** Don't copy — translate.

Example:
- **Visegrad24 original:** "BREAKING: Iran launches 12 ballistic missiles toward Israel"
- **Our version:** "Iran just launched 12 ballistic missiles at Israel. For those keeping score at home, this is the third time this year. The 'de-escalation' is going great."

Store these rewrites in `brand-config.md` under the "Learned Patterns" section. Keep the 10 most recent examples, rotating out old ones.

### Step 4: Detect Topic Gaps
Compare what watch accounts are covering vs. what we've posted (check `post-history.md`):
- Are they covering something we missed? → Generate a tweet about it NOW
- Are they all covering the same story? → That's the story of the day, make sure we have a thread on it
- Is nobody covering something we noticed? → That's our opportunity for an original take

### Step 5: Update Strategy
Append findings to `self-reflection-log.md`:
```
## [DATE TIME] — Account Study + Trend Scan
### Hot Topics Right Now
- [Topic 1]: covered by [accounts], engagement level [high/medium]
- [Topic 2]: covered by [accounts], engagement level [high/medium]

### Voice Learnings
- Best performing format: [observation]
- New few-shot example added: "[example]"
- Hook pattern discovered: [pattern]

### Action Items
- [ ] Post about [topic] — we're behind the curve
- [ ] Try [format] — it's working for [account]
- [ ] Update content mix: more [type], less [type]
```

## Part 2: Trend Riding (Every 2 hours during peak)

### Step 1: What's Trending on X
Search for what's trending in News/World/Politics:
- Web search: "twitter trending topics world news today"
- Web search: "X trending geopolitics today"
- Check if any hashtags related to our niche are trending

### Step 2: Quick-React Content
If a trending topic intersects with our niche:
- Check if we've already posted about it (check `post-history.md`)
- If not, generate a tweet + queue a quote tweet on the biggest post about it
- Use the trending hashtag if there is one
- Speed matters — trending topics have a 2-4 hour window before they're saturated

### Step 3: Track What Trends We Caught vs Missed
In `self-reflection-log.md`, note:
- Trends we posted about within 1 hour: [list]
- Trends we missed: [list]
- Goal: catch 80%+ of relevant trends within the first hour

## Part 3: Auto-Update Brand Config

When you discover patterns that consistently work, update `brand-config.md` directly:

**"Learned Patterns" section — keep updated with:**
- Top 10 few-shot examples (rotate oldest out)
- Current hot topics list (what to tweet about NOW)
- Format that's working this week (e.g., "short punchy tweets under 150 chars outperforming threads")
- Time slots that perform best

**DO NOT change the core voice definition** (the Visegrad24 + Trevor Noah blend). That's the identity. You're refining the execution, not the personality.

## Constraints
- Only study via web search — no private data access
- Don't copy tweets word-for-word — learn patterns, develop original voice
- Keep `brand-config.md` Learned Patterns section under 50 lines (trim old stuff)
- Don't chase trends outside our niche (celebrity drama, sports, etc.)
