# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

davaz.com is a Ruby web application for an artist portfolio site with gallery, shop, guestbook, and content management. It uses a non-Rails stack: **Rack + SBSM (State-Based Session Management) + HtmlGrid (component-based views) + MySQL**.

### Runtime
- Ruby 3.4.5 (`.ruby-version`), Bundler 4.0.7
- Key Ruby 3.4 notes: `require 'ostruct'` is explicit (gem in Gemfile), `String#crypt` rejects newline in salt, `YAML.safe_load` uses keyword args only, `.untaint` removed
- Git LFS tracks `db/*.sql` (see `.gitattributes`)

## Commands

### Run the server
```
bundle exec rackup config.ru
```

### Run all tests
```
bundle exec rake test
```

### Run a single test file
```
bundle exec foreman run ruby -I.:test test/feature/lectures_test.rb
```

### Run a specific test method
```
bundle exec rake test TEST_OPTS="--name=TestLectures#test_lectures_toggle_hidden_dev_links"
```

### Admin console (interactive REPL)
```
bundle exec ./bin/admin
```

## Architecture

### Request Flow
```
HTTP → Rack (config.ru) → RackInterface (util/app.rb) → SBSM State Machine → HtmlGrid Views → HTML Response
```

### Source Layout (`src/`)

- **`state/`** — SBSM state classes define request handling and state transitions. `state/global.rb` is the root state. `state/predefine.rb` defines the state hierarchy. States are organized by section: `gallery/`, `personal/`, `works/`, `communication/`, `public/`, `admin/`. Partials in `state/_partial/` provide reusable mixins (login, AJAX, paging, etc.).

- **`view/`** — HtmlGrid component classes that render HTML. Mirror the state directory structure. `view/template.rb` is the base template. Partials in `view/_partial/` are reusable UI components.

- **`model/`** — Domain models: `ArtObject` (main entity), `ArtGroup`, `Serie`, `Tag`, `Tool`, `Material`, `Guest`, `Link`, `Oneliner`, `Country`.

- **`util/`** — Infrastructure code:
  - `app.rb` — Main App class and RackInterface (Rack entry point)
  - `db_manager.rb` — All database operations (~1200 lines, raw SQL via Mysql2)
  - `session.rb` — Session management
  - `config.rb` — Configuration via RCLConf
  - `image_helper.rb` — Image processing with RMagick
  - `lookandfeel.rb` — Theme/styling configuration
  - `validator.rb` — Form input validation
  - `trans_handler.davaz.rb` — URL translation/routing
  - `youtube_helper.rb` — YouTube Data API v3 integration (view counts and comment counts for movie/short/clip embeds, batched prefetch with 1h cache, 5s HTTP timeouts). `@cache` holds view counts; `@comments_cache` holds comment counts; both populate in a single `part=statistics` API call.

### Key Patterns

- **State machine pattern**: Each page/action is a state class. Navigation happens via state transitions defined in `predefine.rb`. States inherit from `SBSM::State`.
- **Component-based views**: Views are Ruby classes inheriting from HtmlGrid components. UI is composed by mapping named slots to component classes.
- **No ORM**: `DbManager` uses raw SQL queries directly. All DB access goes through the singleton `DaVaz.config.db_manager` or `app.db_manager`.
- **Client-side JS**: Uses Dojo toolkit (1.7.x) in `doc/resources/` for AJAX interactions. Homepage video thumbnail grid uses vanilla JS for infinite scroll.
- **Homepage video grid**: The homepage displays three separate sections (Movies, Shorts, Clips) of shuffled YouTube video thumbnail grids. Video IDs are loaded from the DB (artgroups `MOV`, `SHO`, `CLI`), split by artgroup, shuffled per-section, first 10 per section rendered as HTML, remaining passed to JS for infinite scroll (10 more on scroll). Each section has unique DOM IDs and JS variables to avoid conflicts. Thumbnails use YouTube's static CDN URLs (`img.youtube.com/vi/{id}/hqdefault.jpg`) — no API calls needed. Private/blocked/deleted videos are automatically hidden client-side by checking thumbnail dimensions on load (YouTube returns a 120x90 placeholder for unavailable videos). All MOV/SHO entries are sourced from @gozipa (Enhanced 4K). A type-ahead search bar (`VideoSearchBar` in `view/personal/init.rb`) filters all three sections by title in real time — each section emits a `_videoAll_{section}` JS array with all video data for client-side filtering. The bar is styled with a prominent 2px violet (`#8a2be2`) border and a soft violet glow (see `div.video-search-bar input` in `doc/resources/css/init.css`) so it's visible above the thumbnail grid. The placeholder rotates every 2s through a list of sample queries (`nt`, `chick`, `pi`, `Georgien`, `lim`, `sib`, `visu`, `last`, `uni`, `li`, `com`, `mo`, `Kazakh`) to hint at searchable content; rotation pauses as soon as the user focuses or types. A **tag cloud** of the top ~40 keywords is rendered above the search bar, built server-side in `VideoSearchBar#build_tag_cloud` from titles only (Unicode-aware tokenization, multilingual stopword list, min length 3). Tags are derived from titles so every tag corresponds to something visible on a thumbnail; the search itself, however, matches both title and description (`v[2]` and `v[4]` in the `_videoAll_{section}` tuple) for richer results. Font-size scales with frequency. Clicking a tag sets `input.value` and triggers `doSearch()`. `load_youtube_video_ids` in `db_manager.rb` also selects the `text` column so descriptions are available for client-side search.
- **Homepage ticker**: The horizontal scrolling ticker (`view/_partial/ticker.rb`) shows MOV thumbnails. Falls back to YouTube thumbnails (`mqdefault.jpg`) when no local image exists. CSS uses `object-fit: cover` to crop 16:9 YouTube thumbnails into the 180x180 square slots without distortion.
- **Clips page**: Clips (`/en/works/clips/`) follow the same pattern as Movies and Shorts — state in `state/works/clips.rb`, view in `view/works/clips.rb`, CSS in `doc/resources/css/clips.css`. DB query via `load_clips` (artgroup `CLI`). Includes click-to-play embeds, detail view via AJAX, pager navigation.
- **Movies page sort bar**: `MoviesSortBar` in `view/works/movies.rb` renders a three-button bar (Default / Most views / Most comments) above the movies list. Styled with the page's gray-blue palette (`#738494` accent, `#d8dee4` bar background — see `div.movies-sort-bar` in `doc/resources/css/movies.css`) to match the top navigation. Each `MovieEmbed` outputs `data-views` and `data-comments` attributes on its `.movies-embed-wrapper`, plus a combined "X views · Y comments" caption. Inline JS (wrapped in `DOMContentLoaded`) reorders `#movies_list` children client-side by those attributes — unknown counts sort last (stored as -1). The "Default" button restores the original DB order snapshotted on first sort. No URL state, no page reload.
- **Login**: AJAX login via `view/_partial/login.rb` and `state/_partial/login.rb`. The `LoginForm` must explicitly set its form ACTION to `event_url(:admin, :login)` — HtmlGrid defaults to `base_url` which omits the event, breaking SBSM event routing. Passwords are stored as `crypt()`-hashed entries in `etc/pw_server.passwords` using the salt from `etc/pw_server.salt`. Use `bin/generate_passwd_entry` to create entries.

### Testing

Tests use **Minitest** with **Watir 7 / Selenium WebDriver 4** for headless browser feature tests (Chrome or Firefox). Feature tests are in `test/feature/`. Mocking uses **Flexmock**. Coverage tracked via **SimpleCov**.

- Watir 7 uses keyword args for element locators: `div(id: 'foo')` not `div(:id, 'foo')`
- Test server starts on port 11090 (see `test/config.ru` and `test/support/server.rb`)
- Test stubs: `test/support/stub/db_manager.rb` replaces real DB; `test/pw_server.passwords` has test credentials
- Dojo toolkit is auto-downloaded on first test run
- `Rack::Lint` is NOT used in test config — sbsm's `body.rewind` call is incompatible with Rack 3.x Lint wrapper
- Default Watir timeout is 15 seconds (`TEST_CLIENT_TIMEOUT` in `test/test_helper.rb`)

### Current test status
27 runs, 159 assertions, 0 failures, 0 errors, 5 skips. The 5 skips are known limitations:
- Stub db_manager does not support creating/updating art objects
- Shop validation error messages not displayed in test environment
- Movie thumbnail image not found during tests
- Postal code validation message not shown

Note: The admin movies WYSIWYG editor test (`test_admin_movies_update_description_text_by_wysiwyg_editor`) has a known flaky cursor position issue in headless Chrome — the Dojo editor sometimes appends text instead of prepending.

## Configuration

- `etc/db_connection_data.yml` — MySQL credentials (copy from `.sample`)
- `etc/pw_server.passwords` — Authentication credentials
- `etc/pw_server.salt` — Password salt
- `.yt-keys` — YouTube Data API v3 keys (one per line, `#` for comments). Used to display view counts on movie and short embeds. Supports multiple keys for different YouTube accounts. Keys are read from project root first, then `~/.yt-keys`. Falls back to `YOUTUBE_API_KEY` / `YOUTUBE_API_KEY_2` env vars. App works without keys (view counts simply not shown).

### YouTube 4K Migration Scripts (`bin/`)

- `rebuild_movies_shorts_from_gozipa.rb` — **Primary rebuild script.** Deletes all MOV/SHO entries and recreates them exclusively from @gozipa's Videos and Shorts tabs via yt-dlp. Deduplicates by normalized title (prefers Enhanced 4K versions). Uses YouTube titles and descriptions. Strips emojis for MySQL `utf8` compatibility. Classifies by Shorts tab membership or duration: <=60s → `SHO`, >60s → `MOV`. Fetches upload dates from YouTube API v3 (Step 6).
- `update_4K_shorts_movies_yt.rb` — Legacy incremental updater. Scans @jdavatz and @gozipa channels, updates existing entries to 4K URLs, creates missing entries.
- `update_youtube_4k` — Older updater using CSV or YouTube API mode.
- `fetch_clips_from_feed.rb` — Fetches clip metadata from authenticated `/feed/clips` pages using exported Netscape-format cookie files. Merges multiple accounts into `json/clips.json` (deduplicated by clip_id). Extracts clip_url, title, source_video_id, and duration from the page's `ytInitialData` — no yt-dlp required. Cookie files must never be committed to git.
- `import_clips` — Reads `json/clips.json` and inserts/updates DB entries with proper `youtube.com/clip/` URLs. Supports `--fetch` (legacy: download metadata via yt-dlp from `csv/clip_urls.txt`) and `--apply` (write to DB). The `--fetch` mode now requires cookies because yt-dlp hit YouTube's bot challenges; prefer `fetch_clips_from_feed.rb` instead.
- `send_email_gmail.py` — Sends email via Gmail API (OAuth2), uses same credentials as [old2new](https://github.com/zdavatz/old2new)

### YouTube Clips

YouTube Clips (artgroup `CLI`) are short segments clipped from existing videos. They use `youtube.com/clip/CLIP_ID` URLs (not regular watch URLs) so they play the clip segment, not the full video. Clips can't be iframe-embedded — they link directly to YouTube. Clip metadata is stored in `json/clips.json`, which provides the `CLIP_SOURCE_VIDEOS` mapping (clip ID → source video ID) used for thumbnail images. The clips feed (`https://www.youtube.com/feed/clips`) requires authentication — clip URLs must be extracted from the browser, then metadata fetched via `bin/import_clips --fetch`.

**Important**: `clips.json` must be read with `encoding: 'utf-8'` because the daemontools service runs without a UTF-8 locale (Ruby defaults to US-ASCII). The `ClipImage` view falls back to YouTube thumbnails (via source video ID) when no local image file exists.

`YoutubeHelper.clip_source_videos` caches the parsed `clips.json` in memory but reloads automatically when the file's mtime changes — so adding new clips doesn't require a service restart. If a clip's `source_video_id` lookup fails, the homepage grid silently drops the entry.

### Adding Individual Videos Manually

When adding individual Enhanced 4K videos (not a full rebuild), use the YouTube Data API v3 to fetch title, description, duration, and upload date. Before inserting, always check for existing entries with the same video ID or similar normalized title to avoid duplicates. Classification: <=60s → `SHO`, >60s → `MOV`. Strip emojis from title/description for MySQL `utf8` compatibility. Set the upload date from the API's `publishedAt` field. If the new video is a 4K replacement for an existing non-4K entry, delete the old entry after inserting the new one.
