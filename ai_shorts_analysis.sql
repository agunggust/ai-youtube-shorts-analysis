-- In the SQLite CLI, run these commands from the folder with both files.
-- .import --csv ai_shorts_jun_jul_2025.csv shorts
-- .read ai_shorts_analysis.sql
-- Each channel contributes its own median to the channel-weighted result.

WITH cohort AS (
    SELECT
        video_id,
        format,
        channel_handle,
        CAST(views AS INTEGER) AS views
    FROM shorts
    WHERE published_date_youtube_ui BETWEEN '2025-06-01' AND '2025-07-31'
      AND observed_date_jakarta = '2026-11-12'
      AND NULLIF(views, '') IS NOT NULL
),
ranked_within_channel AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY format, channel_handle ORDER BY views, video_id
        ) AS position,
        COUNT(*) OVER (PARTITION BY format, channel_handle) AS channel_videos
    FROM cohort
),
channel_medians AS (
    SELECT format, channel_handle, AVG(views) AS median_views
    FROM ranked_within_channel
    WHERE position IN ((channel_videos + 1) / 2, (channel_videos + 2) / 2)
    GROUP BY format, channel_handle
),
observations AS (
    SELECT 'video' AS unit, format, video_id AS id, views AS views_value
    FROM cohort
    UNION ALL
    SELECT 'channel', format, channel_handle, median_views
    FROM channel_medians
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY unit, format ORDER BY views_value, id) AS position,
        COUNT(*) OVER (PARTITION BY unit, format) AS sample_size
    FROM observations
)
SELECT unit, format, sample_size, AVG(views_value) AS median_views
FROM ranked
WHERE position IN ((sample_size + 1) / 2, (sample_size + 2) / 2)
GROUP BY unit, format, sample_size
ORDER BY unit DESC, format;

-- Use the displayed like count, including counts rounded by YouTube.
WITH rates AS (
    SELECT
        video_id,
        format,
        likes_precision,
        1000.0 * CAST(likes AS INTEGER) / CAST(views AS INTEGER) AS likes_per_1000
    FROM shorts
    WHERE published_date_youtube_ui BETWEEN '2025-06-01' AND '2025-07-31'
      AND observed_date_jakarta = '2026-11-12'
      AND CAST(views AS INTEGER) > 0
      AND NULLIF(likes, '') IS NOT NULL
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY format ORDER BY likes_per_1000, video_id) AS position,
        COUNT(*) OVER (PARTITION BY format) AS sample_size,
        SUM(likes_precision = 'rounded') OVER (PARTITION BY format) AS rounded_counts
    FROM rates
)
SELECT
    format,
    sample_size,
    rounded_counts,
    ROUND(AVG(likes_per_1000), 1) AS median_likes_per_1000_views
FROM ranked
WHERE position IN ((sample_size + 1) / 2, (sample_size + 2) / 2)
GROUP BY format, sample_size, rounded_counts
ORDER BY format;
