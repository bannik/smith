# Heartbeat Schedule — The Audacity Timeline

## MODE: BOOTSTRAP AUTONOMOUS (full auto, laptop running for hours)

Agent runs fully autonomously. No approval needed for posting. Interaction is steady but not spammy — sustainable for hours of continuous operation without hitting rate limits.

## Content Generation
- **Single tweets:** Every 2.5 hours (06:00, 08:30, 11:00, 13:30, 16:00, 18:30, 21:00 UTC)
- **Threads:** Twice per day:
  - Morning: 08:00-10:00 UTC (EU audience)
  - Afternoon: 15:00-17:00 UTC (US+EU overlap)
- **Substack draft:** Weekly, Sundays at 14:00 UTC

## News Monitoring (Always On)
- **News scan:** Every 20 minutes — check for breaking stories
- **Breaking story detected (score 8+):** Post immediately, thread within 20 min, 2 QTs within 30 min
- **Notable story (score 5-7):** Post within next scheduled tweet slot
- Read `skills/news-monitor/SKILL.md` for full scoring system

## Engagement (Steady, Not Spammy)
Peak window: 13:00-22:00 UTC

- **Quote tweets:** 1-2 every 90 minutes during peak. Max 8 per day.
- **Likes:** 8-10 every 90 minutes during peak. Target: 50/day.
- **Follows:** 3-4 every 3 hours. Max 15/day.
- **Off-peak (22:00-13:00):** 1 QT + 5 likes every 3 hours.
- **Cold replies: STILL BLOCKED.** Test one per day. Use QTs instead.

## Learning + Trend Detection
- **Account study + trend scan:** Every 4 hours (06:00, 10:00, 14:00, 18:00, 22:00 UTC)
- **Quick trend check:** Every 2 hours during peak — are we missing something hot?
- **Update brand-config.md** with new few-shot examples and hot topics after each study
- Read `skills/learn-accounts/SKILL.md` for full process

## Self-Management
- **Self-reflection:** Daily at 22:00 UTC
- **Telegram report:** Daily at 22:30 UTC
- **Budget check:** Every 2 hours — stay within spending cap

## Rate Limit Safety (for sustained laptop running)
- Minimum 3 minutes between ANY post (tweet, QT, thread tweet)
- Minimum 30 seconds between likes
- Minimum 1 minute between follows
- If ANY 429 response: back off 15 minutes, halve the rate for 1 hour, then gradually resume
- Max API calls per hour: 60 (well under Twitter's limits)
- If laptop has been running 8+ hours straight, reduce all frequencies by 30% to avoid looking automated

## Priority Order
1. Breaking news posts (time-sensitive, highest value)
2. Quote tweets on viral posts (growth engine)
3. Scheduled threads (reach multiplier)
4. Trend-riding tweets with hashtags (discovery)
5. Regular tweets (presence)
6. Likes (interaction history building)
7. Follows (background growth)
8. Account study (can defer if busy)

## Breaking News Override
When news-monitor scores a story 8+:
- STOP whatever scheduled content was next
- Post breaking tweet within 2 minutes
- Start thread within 20 minutes
- Queue 2 quote tweets on big accounts covering it
- Stay on the story for 2 hours (follow-up tweets if developments continue)
- Then resume normal schedule
