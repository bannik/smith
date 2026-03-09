## 2026-03-09 10:17 UTC — Account Study (12:00 UTC scheduled)

### Accounts studied: visegrad24, sentdefender, NOELreports, IntelCrab

### Top performing content (48h)

**@visegrad24** — Best: "BREAKING: A new round of airstrikes hitting Isfahan" (1,902 likes, 324 RTs)
- Pure news, one sentence, no commentary — just the fact
- "BREAKING:\n\n" format with line break before content performs well
- Video/image attachments on every top tweet

**@sentdefender** — Best: B-1B bombers taking off (3,867 likes, 286 RTs)
- Military hardware posts with images dominate
- Oil price updates with exact numbers perform extremely well (2,083 likes)
- Footage posts — video content is their #1 driver

**@NOELreports** — Smaller numbers but consistent
- Hyper-specific detail (unit names, locations) signals credibility
- US casualty posts get highest reply rate

### Key patterns to apply:

1. **Line break after BREAKING:** — visegrad24 uses `BREAKING:\n\n` not `BREAKING:` inline
2. **Exact numbers work** — "$116/barrel" beats "oil prices rose"
3. **Video/images drive massive engagement** — our text-only tweets are at a disadvantage
4. **Military hardware content** — sentdefender's top post is literally just bombers taking off
5. **Speed > polish** — these accounts post within minutes of events, not hours

### Action items:
- Adopt the `BREAKING:\n\n` format in next tweets
- Include exact figures when available (barrel price, troop counts, etc.)
- Consider adding images/maps to posts when sourced properly

## 2026-03-09 — Daily Self-Reflection (Day 1)

### Performance Summary
- **Tweets posted:** 12 (2 threads × 6 tweets + 4 standalone + 2 auto)
- **Retweets by us:** 5 (zerohedge 2.6M, PIIE 109K, shahidovcom 68K, tparsi 182K, adaderana 512K)
- **Likes given:** 66
- **Follows:** 9 (Reuters, AP, visegrad24, sentdefender, NOELreports, IntelCrab, BNONews + 2 smaller)
- **Followers gained:** unknown (no follower tracking API yet)
- **Account age:** Day 1 of active operation (created March 7)

### What Worked
1. **Thread format** — Both threads (Iran succession + day 10 recap) were the strongest content. The 6-tweet thread structure with a cliffhanger opener gets people to keep reading.
2. **Dry one-liners** — "Canada promised to be different. Then Washington called. These things happen." is the kind of tweet that gets screenshotted.
3. **Exact numbers** — "Oil at $116/barrel" and "$200/barrel" framings generated more engagement signal than vague references.
4. **Cron automation** — 30-min cycle ran 10 successful consecutive cycles after initial timeout issues were fixed. Clean and sustainable.

### What Didn't Work
1. **API reply/QT restriction** — New account can't cold-reply or QT via API. Biggest growth blocker. Manual workaround in place (Bannik handles replies).
2. **News scoring threshold too high** — Set at 5, caused the Rubio "systematically destroying Iran's military" story to be skipped (scored 4). Should be 3.
3. **Duplicate tweet content** — Auto-cycle posted "Day 9" when it was actually Day 10. Need to dynamically calculate day count.
4. **Watch account engagement** — Followed 9 big accounts but no follow-backs yet (expected given account age).

### Strategy Adjustments
- Lower news scoring threshold from 5 → 3 in bootstrap-cycle.py
- Fix day count calculation (dynamic, not hardcoded)
- Add follow-back check to engagement routine
- Keep threads as primary content (2/day) — they're the best reach vehicle

### Tomorrow's Focus
1. Post morning thread early (07:00-08:00 UTC) — EU audience
2. Generate 3 standalone tweets across the day
3. Let Bannik handle 5-10 manual replies (high-value growth lever he can do, API can't)
4. RT 3-5 accounts per cycle (working well)
5. Push toward 80+ likes/day
6. Test one cold reply via API to check if restriction lifted

### One Thing To Do Differently
The auto-cycle tweets are a bit generic ("BREAKING: Day X of the war..."). Need better templates that feel more like genuine commentary, less like a bot filling a slot. Tomorrow: generate 5 pre-written tweet templates and rotate them based on the day's top story angle.
