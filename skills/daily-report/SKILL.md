---
name: daily-report
description: Send daily performance report to Telegram
triggers:
  - daily report
  - send report
  - telegram report
---

# Daily Telegram Report

Send a formatted daily performance summary to the owner via Telegram at 22:30 UTC.

## Telegram API

**Endpoint:** `POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`

**Body:**
```json
{
  "chat_id": "${TELEGRAM_CHAT_ID}",
  "text": "YOUR_MESSAGE",
  "parse_mode": "Markdown"
}
```

## Report Format

```markdown
📊 *The Audacity Timeline — Daily Report*
📅 [DATE]

*Content*
• Tweets posted: [X]
• Threads: [X]
• Quote tweets: [X]
• Replies to trending: [X]

*Engagement Received*
• Likes: [X] | Replies: [X] | RTs: [X]
• New followers: [X] (total: [X])
• Profile visits: [X] (if available)

*Engagement Given*
• Likes: [X] | Follows: [X] | QTs: [X]
• Replies posted: [X]

*Top Tweet*
"[text of best-performing tweet]"
→ [likes] ❤️ [RTs] 🔁 [replies] 💬

*Self-Reflection Insight*
[Most important insight from today's self-reflection]

*Strategy for Tomorrow*
[1-2 sentence plan]

*API Budget*
• Today: $[X] | Month-to-date: $[X] / $50
• Projected monthly: $[X]

[STATUS_EMOJI] Status: [Running normally / Budget warning / Rate limited]
```

## Data Sources

Pull data from:
- `post-history.md` — tweet count, content
- `engagement-log.md` — engagement metrics
- `self-reflection-log.md` — today's insights
- `api-costs.md` — budget tracking

## Error Handling

If Telegram send fails:
- Retry once after 30 seconds
- If still failing, log the report to `self-reflection-log.md` with a note that Telegram delivery failed
- Don't block on Telegram failures — the report data is still valuable locally
