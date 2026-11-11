# AI YouTube Shorts Performance

Which format should a creator test first if their goal is to reach more viewers? I compared surreal ASMR with Bigfoot/Yeti comedy vlogs across 40 YouTube Shorts uploaded in June 2025.

| Metric | Surreal ASMR | Bigfoot/Yeti comedy |
|---|---:|---:|
| Videos | 20 | 20 |
| Channels | 18 | 19 |
| Median views per video | 253,980.5 | 39,540 |
| Median views with equal weight per channel | 253,980.5 | 35,059 |
| Median likes per 1,000 views | ≈9.7 (20 videos) | ≈13.1 (19 videos) |

Surreal ASMR had 7.2× the median views when each channel counted equally. Removing each channel in turn produced medians of 227,517–280,444 for ASMR and 18,811.5–40,748.5 for comedy. Comedy had more likes per 1,000 views at the median, using public counts that YouTube sometimes rounded.

## Data and method

- I used YouTube's Shorts filter with the queries below and screened the results in their displayed order. The log records 56 candidates, including a comedy candidate screened beyond the quota before an earlier video with zero views was confirmed.
- I took the first 20 eligible results per format, with at most two videos per channel. Videos had to be uploaded in June 2025 and show an AI label or an AI or Veo 3 reference in the title or description. I screened out identifiable tutorials and compilations, and skipped one ASMR candidate whose format was unclear.
- I recorded public counts on November 12, 2026, Jakarta time. Each included row has a video ID, channel, upload date, AI evidence type, and source link.
- I first took the median across videos within each format. For the channel comparison, I took each channel's median views within its format, then took the median across those channel values.
- I calculated likes per 1,000 views for each video with positive views and a displayed like count, then took the median by format. One comedy clip had zero views. YouTube displayed rounded counts for 12 ASMR clips and nine comedy clips.
- The sample reflects the ranked results visible in one browsing session. Search order can vary, upload dates still differ within June, and each view count reflects cumulative exposure at the time of collection. The analysis is descriptive.

```text
glass fruit cutting AI ASMR #shorts after:2025-05-31 before:2025-07-01
AI bigfoot yeti vlog veo 3 #shorts after:2025-05-31 before:2025-07-01
```

## Creator experiment

For a creator prioritizing reach, test surreal ASMR first. Publish six ASMR and six comedy clips on the same channel, randomize their order across comparable posting slots, and measure each video after seven days. Compare median views as the primary outcome and likes per 1,000 views as a secondary measure.

## Reproduce the analysis

Run these commands in a new SQLite CLI session from the folder with the [screening log](ai_shorts_june_2025_screening.csv), [cohort query](ai_shorts_june_2025.sql), and [shared metrics query](ai_shorts_analysis.sql).

```text
.import --csv ai_shorts_june_2025_screening.csv screening
.headers on
.mode column
.read ai_shorts_june_2025.sql
```

## CV bullet

> Screened 56 YouTube Shorts and analyzed 40 AI clips across 37 channels in SQLite, comparing views and likes and testing whether the results held when individual channels were removed.
