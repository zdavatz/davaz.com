---
name: youtube-videos
description: YouTube video management for davaz.com — the /api/videos endpoint reference (auth, request/response, tag-color sniffing), the 4K migration/rebuild scripts in bin/, and the procedure for adding individual videos manually (classification thresholds, dedup, emoji stripping). Use when adding videos, running rebuilds/imports, or working on the video API.
---

# YouTube video management

## Video API (`/api/videos`)

A Rack middleware (`src/util/api_videos.rb`) wired before SBSM in `config.ru` exposes a stateless JSON API for adding YouTube videos to the artobjects table. Auth is via `Authorization: Bearer <token>` against `etc/api_tokens` (constant-time comparison via `Rack::Utils.secure_compare`). Only `POST /api/videos` is handled; everything else falls through to the SBSM stack.

Request body (JSON):
```json
{
  "url": "https://www.youtube.com/watch?v=...",
  "tag_color": "yellow"  // optional: "yellow" → promoted (gold), "purple" → promoted_violet, "red" → promoted_red, "green" → promoted_green
}
```

Behavior: extracts the video ID via `YoutubeHelper.extract_video_id`, returns `409` if a row with that URL already exists, fetches `snippet,contentDetails` from the YouTube API (using `.yt-keys`), strips emojis from title/description (MySQL `utf8` compat), classifies by duration (`<=80s` CLI, `81-240s` SHO, `>=241s` MOV — same rule as individual additions below), inserts via `db.insert_artobject`, and optionally appends `[title, title.downcase]` to the matching bucket in `json/promoted_tags.json`. Returns `201` with `{ id, artgroup_id, title, url, duration_seconds, tag_added }`. Status codes: `400` invalid JSON, `401` missing/wrong token, `404` video not on YouTube, `405` non-POST, `409` already exists, `422` missing/unrecognized URL, `502` YouTube API failed.

**Tag-color sniffing**: if `tag_color` is omitted (or set to an unrecognized value), the API scans the description text for any recognized color name (`yellow`, `purple`, `red`, `green`) as a **whole word, anywhere** in the text — the earliest occurrence wins. Whole-word matching avoids false positives like "credits" (substring `red`) or "purposefully" (substring `purple`). This makes the convention of writing the color name in the YouTube description work automatically; GUI clients (e.g. `create_shorts_gui`) don't need to know the color list. To disable or override, pass an explicit `tag_color` in the body. The mapping `color → bucket` is centralized in `ApiVideos::TAG_COLOR_BUCKETS` — **adding a new color is server-only**: add a key there + a sibling array in `json/promoted_tags.json` + a `.video-tag-promoted-<color>` CSS rule.

Tests are unit-level (`test/api_videos_test.rb`) using `Rack::MockRequest` with a fake DbManager and a stubbed `fetch_metadata` — no live server or YouTube calls. The test suite covers auth, method gating, classification thresholds, duplicate detection, and validation errors.

## YouTube 4K Migration Scripts (`bin/`)

- `rebuild_movies_shorts_from_gozipa.rb` — **Primary rebuild script.** Deletes all MOV/SHO entries and recreates them exclusively from @gozipa's Videos and Shorts tabs via yt-dlp. Deduplicates by normalized title (prefers Enhanced 4K versions). Uses YouTube titles and descriptions. Strips emojis for MySQL `utf8` compatibility. Classifies by Shorts tab membership or duration: <=60s → `SHO`, >60s → `MOV`. Fetches upload dates from YouTube API v3 (Step 6).
- `update_4K_shorts_movies_yt.rb` — Legacy incremental updater. Scans @jdavatz and @gozipa channels, updates existing entries to 4K URLs, creates missing entries.
- `update_youtube_4k` — Older updater using CSV or YouTube API mode.
- `fetch_clips_from_feed.rb` — Fetches clip metadata from authenticated `/feed/clips` pages using exported Netscape-format cookie files. Merges multiple accounts into `json/clips.json` (deduplicated by clip_id). Extracts clip_url, title, source_video_id, and duration from the page's `ytInitialData` — no yt-dlp required. Cookie files must never be committed to git.
- `import_clips` — Reads `json/clips.json` and inserts/updates DB entries with proper `youtube.com/clip/` URLs. Supports `--fetch` (legacy: download metadata via yt-dlp from `csv/clip_urls.txt`) and `--apply` (write to DB). The `--fetch` mode now requires cookies because yt-dlp hit YouTube's bot challenges; prefer `fetch_clips_from_feed.rb` instead.
- `send_email_gmail.py` — Sends email via Gmail API (OAuth2), uses same credentials as [old2new](https://github.com/zdavatz/old2new)

## Adding Individual Videos Manually

When adding individual Enhanced 4K videos (not a full rebuild), use the YouTube Data API v3 to fetch title, description, duration, and upload date. Before inserting, always check for existing entries with the same video ID or similar normalized title to avoid duplicates. Classification by duration: ≤80s (≤1:20) → `CLI`, 81–240s (1:21–4:00) → `SHO`, ≥241s (≥4:01) → `MOV`. Note: this differs from `rebuild_movies_shorts_from_gozipa.rb`'s legacy `<=60s → SHO, >60s → MOV` rule — the duration thresholds above apply to individual additions only and are not applied retroactively. Strip emojis from title/description for MySQL `utf8` compatibility. Set the upload date from the API's `publishedAt` field. If the new video is a 4K replacement for an existing non-4K entry, delete the old entry after inserting the new one.
