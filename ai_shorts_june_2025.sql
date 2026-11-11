-- Run in a new SQLite CLI session from the project directory.
-- .import --csv ai_shorts_june_2025_screening.csv screening
-- .read ai_shorts_june_2025.sql

CREATE TEMP VIEW shorts AS
SELECT *
FROM screening
WHERE screening_status = 'included';

.read ai_shorts_analysis.sql

-- Recalculate the format median after removing each channel in turn.
WITH ranked_videos AS (
    SELECT
        format,
        channel_handle,
        CAST(views AS INTEGER) AS views,
        ROW_NUMBER() OVER (
            PARTITION BY format, channel_handle ORDER BY CAST(views AS INTEGER), video_id
        ) AS position,
        COUNT(*) OVER (PARTITION BY format, channel_handle) AS video_count
    FROM shorts
),
channel_medians AS (
    SELECT format, channel_handle, AVG(views) AS median_views
    FROM ranked_videos
    WHERE position IN ((video_count + 1) / 2, (video_count + 2) / 2)
    GROUP BY format, channel_handle
),
ranked_remaining_channels AS (
    SELECT
        omitted.format,
        omitted.channel_handle AS omitted_channel,
        kept.median_views,
        ROW_NUMBER() OVER (
            PARTITION BY omitted.format, omitted.channel_handle
            ORDER BY kept.median_views, kept.channel_handle
        ) AS position,
        COUNT(*) OVER (
            PARTITION BY omitted.format, omitted.channel_handle
        ) AS channel_count
    FROM channel_medians AS omitted
    JOIN channel_medians AS kept
      ON kept.format = omitted.format AND kept.channel_handle <> omitted.channel_handle
),
scenarios AS (
    SELECT format, omitted_channel, AVG(median_views) AS format_median
    FROM ranked_remaining_channels
    WHERE position IN ((channel_count + 1) / 2, (channel_count + 2) / 2)
    GROUP BY format, omitted_channel
)
SELECT
    format,
    COUNT(*) AS channels_tested,
    MIN(format_median) AS min_median_views,
    MAX(format_median) AS max_median_views
FROM scenarios
GROUP BY format
ORDER BY format;
