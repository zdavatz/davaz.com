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

### Key Patterns

- **State machine pattern**: Each page/action is a state class. Navigation happens via state transitions defined in `predefine.rb`. States inherit from `SBSM::State`.
- **YouTube stats integration**: `util/youtube_helper.rb` — YouTube Data API v3 integration (view counts and comment counts for movie/short/clip embeds, batched prefetch with 1h cache, 5s HTTP timeouts). `@cache` holds view counts; `@comments_cache` holds comment counts; both populate in a single `part=statistics` API call.
- **Component-based views**: Views are Ruby classes inheriting from HtmlGrid components. UI is composed by mapping named slots to component classes.
- **No ORM**: `DbManager` uses raw SQL queries directly. All DB access goes through the singleton `DaVaz.config.db_manager` or `app.db_manager`.
- **Client-side JS**: Uses Dojo toolkit (1.7.x) in `doc/resources/` for AJAX interactions. Homepage video thumbnail grid uses vanilla JS for infinite scroll.
- **Panorama viewer**: 360° panoramas on `/works/multiples/` are rendered by the bundled Pannellum library (`doc/resources/javascript/pannellum/`). The page embeds `pannellum.htm?panorama=...` as a static asset (loaded via `multiples.rb`). The bundled version was upgraded from 2.2.1 to a newer 2.x build (April 2024) — adds mobile orientation control, `cursor:grab`/`grabbing`, broader fullscreen prefix support, and `contain:content` perf hint. The previous 2.2.1 version is kept as `pannellum.htm_back` (untracked).
- **Homepage video grid**: The homepage displays three separate sections (Movies, Shorts, Clips) of shuffled YouTube video thumbnail grids. Video IDs are loaded from the DB (artgroups `MOV`, `SHO`, `CLI`), split by artgroup, shuffled per-section, first 10 per section rendered as HTML, remaining passed to JS for infinite scroll (10 more on scroll). Each section has unique DOM IDs and JS variables to avoid conflicts. Thumbnails use YouTube's static CDN URLs (`img.youtube.com/vi/{id}/hqdefault.jpg`) — no API calls needed. Private/blocked/deleted videos are automatically hidden client-side by checking thumbnail dimensions on load (YouTube returns a 120x90 placeholder for unavailable videos). All MOV/SHO entries are sourced from @gozipa (Enhanced 4K). A type-ahead search bar (`VideoSearchBar` in `view/personal/init.rb`) filters all three sections by title in real time — each section emits a `_videoAll_{section}` JS array with all video data for client-side filtering. The bar is styled with a prominent 2px violet (`#8a2be2`) border and a soft violet glow (see `div.video-search-bar input` in `doc/resources/css/init.css`) so it's visible above the thumbnail grid. The placeholder rotates every 2s through a list of sample queries (`nt`, `chick`, `pi`, `Georgien`, `lim`, `sib`, `visu`, `last`, `uni`, `li`, `com`, `mo`, `Kazakh`) to hint at searchable content; rotation pauses as soon as the user focuses or types. A **tag cloud** of the top ~40 keywords is rendered above the search bar, built server-side in `VideoSearchBar#build_tag_cloud` from titles only (Unicode-aware tokenization, multilingual stopword list, min length 3). Tags are derived from titles so every tag corresponds to something visible on a thumbnail; the search itself, however, matches both title and description (`v[2]` and `v[4]` in the `_videoAll_{section}` tuple) for richer results. Font-size scales with frequency. Clicking a tag sets `input.value` and triggers `doSearch()`. `load_youtube_video_ids` in `db_manager.rb` also selects the `text` column so descriptions are available for client-side search. Curated tags live in `json/promoted_tags.json` (loaded by `YoutubeHelper.promoted_tags` / `promoted_tags_violet` / `promoted_tags_red` / `promoted_tags_green` with mtime-based reload — no service restart needed after editing the JSON). The file has four arrays, `promoted` (gold), `promoted_violet`, `promoted_red`, and `promoted_green`, each entry `[display label, search query]`. Gold tags render with the `.video-tag-promoted` class (gold styling in `doc/resources/css/init.css`) and rely on the search's title-or-description match to find videos whose terms are only in the description (e.g. `Prix de Bâle`). `active_promoted_tags(videos)` filters the gold list down to entries whose query (case-insensitive substring) matches at least one video's title or `text` — entries with zero matches are silently dropped so every visible tag is guaranteed to find videos. The kept gold tags are spread evenly across the violet derived tags by `render_tag_cloud` (positions computed via `((i + 1) * (n_d + 1) / (n_p + 1)).round`) so they are interleaved rather than grouped at the start. If a gold tag's display label collides with a word that would otherwise appear as a violet derived tag (e.g. `love`, `castelbel`), add the lowercase form to the `stopwords` array in `json/promoted_tags.json` (loaded by `YoutubeHelper.stopwords` with the same mtime-based reload — no service restart needed) so the same word doesn't render twice (once gold, once violet). The `promoted_violet` array covers manually curated tags that should look like derived tags — rendered with the plain `.video-tag` class (no gold accent, no font scaling). Use it for entries that wouldn't appear automatically: multi-word labels (e.g. `Male Mating`) or labels whose match is in descriptions only. `render_tag_cloud` prepends violet manual tags to the derived list before spreading gold tags across the combined violet pool. The `promoted_red` array is rendered the same way but with the `.video-tag-promoted-red` class (pale-red pill, dark-red text, no font scaling) — use it for a third visually distinct curated set. Red tags render before violet manual tags, so they appear first in the cloud. The `promoted_green` array is rendered with the `.video-tag-promoted-green` class (pale-green pill, dark-green text, no font scaling) — a fourth visually distinct curated set. Green tags render before red tags, so they appear first in the cloud.
- **Homepage ticker**: The horizontal scrolling ticker (`view/_partial/ticker.rb`) shows MOV thumbnails. Falls back to YouTube thumbnails (`mqdefault.jpg`) when no local image exists. CSS uses `object-fit: cover` to crop 16:9 YouTube thumbnails into the 180x180 square slots without distortion.
- **Clips page**: Clips (`/en/works/clips/`) follow the same pattern as Movies and Shorts — state in `state/works/clips.rb`, view in `view/works/clips.rb`, CSS in `doc/resources/css/clips.css`. DB query via `load_clips` (artgroup `CLI`). Includes click-to-play embeds, detail view via AJAX, pager navigation.
- **Movies page sort bar**: `MoviesSortBar` in `view/works/movies.rb` renders a three-button bar (Default / Most views / Most comments) above the movies list. Styled with the page's gray-blue palette (`#738494` accent, `#d8dee4` bar background — see `div.movies-sort-bar` in `doc/resources/css/movies.css`) to match the top navigation. Each `MovieEmbed` outputs `data-views` and `data-comments` attributes on its `.movies-embed-wrapper`, plus a "4K: X views · Y comments" caption. Inline JS (wrapped in `DOMContentLoaded`) reorders `#movies_list` children client-side by those attributes — unknown counts sort last (stored as -1). The "Default" button restores the original DB order snapshotted on first sort. `data-views` / `data-comments` carry the **aggregate** (4K + original) so videos with both versions rank fairly against single-version videos; the displayed numbers stay split across the two lines. No URL state, no page reload.
- **Original (non-4K) stats on movies page**: When a 4K `@gozipa` video has a known `@jdavatz` original, `MovieEmbed` renders a second stats line ("Original: …") below the 4K line, in a dimmer gray. The Original line is wrapped in an `<a target="_blank" rel="noopener">` pointing to `youtube.com/watch?v={jdavatz_id}` so clicking it opens the original video in a new tab. The mapping `{gozipa_id: jdavatz_id}` lives in `json/movie_originals.json`, generated by `bin/build_movie_originals.rb` via yt-dlp + normalized-title matching (same `normalize_title` rules as the rebuild script). `YoutubeHelper.original_video_ids` loads the JSON with mtime-based cache invalidation (so adding new mappings doesn't require a restart). `prefetch_view_counts` adds the original IDs to the same batched `videos?part=statistics` API call — one API round-trip serves both lines.
- **Login**: AJAX login via `view/_partial/login.rb` and `state/_partial/login.rb`. The `LoginForm` must explicitly set its form ACTION to `event_url(:admin, :login)` — HtmlGrid defaults to `base_url` which omits the event, breaking SBSM event routing. Passwords are stored as `crypt()`-hashed entries in `etc/pw_server.passwords` using the salt from `etc/pw_server.salt`. Use `bin/generate_passwd_entry` to create entries.
- **Heredoc strings with line wrapping**: When a multi-line heredoc represents a single visible paragraph (e.g. `intro_text` in `lookandfeel.rb`), use `<<~TEXT.gsub(/\n/, ' ').strip` — collapsing newlines to **spaces**, not empty string, so words from adjacent source lines don't get glued together (`for\nthe` → `for the`, not `forthe`). Use explicit `<br>` for intentional line breaks inside the paragraph.
- **`<comma/>` placeholder in dojo props**: `HtmlGrid::Component#escape` (in `src/ext/htmlgrid/component.rb`) replaces `,` with `<comma/>` and `\n` with `<br/>` so values can be embedded in the comma-separated `data-dojo-props` attribute. Any Dojo widget that consumes those values via `innerHTML` must decode `<comma/>` back to `,` before rendering — otherwise commas in the source text show up literally as `<comma/>`. Both `live_editor.js` and `oneliner.js` apply `value.replace(/<comma[^>]*>/g, ',')`.

### Testing

Tests use **Minitest** with **Watir 7 / Selenium WebDriver 4** for headless browser feature tests (Chrome or Firefox). Feature tests are in `test/feature/`. Mocking uses **Flexmock**. Coverage tracked via **SimpleCov**.

- Watir 7 uses keyword args for element locators: `div(id: 'foo')` not `div(:id, 'foo')`
- Test server starts on port 11090 (see `test/config.ru` and `test/support/server.rb`)
- Test stubs: `test/support/stub/db_manager.rb` replaces real DB; `test/pw_server.passwords` has test credentials
- Dojo toolkit is auto-downloaded on first test run
- `Rack::Lint` is NOT used in test config — sbsm's `body.rewind` call is incompatible with Rack 3.x Lint wrapper
- Default Watir timeout is 15 seconds (`TEST_CLIENT_TIMEOUT` in `test/test_helper.rb`)

### Known test limitations
Some tests are skipped by design (run the suite for current counts):
- Stub db_manager does not support creating/updating art objects
- Shop validation error messages not displayed in test environment
- Movie thumbnail image not found during tests
- Postal code validation message not shown

Note: The admin movies WYSIWYG editor test (`test_admin_movies_update_description_text_by_wysiwyg_editor`) has a known flaky cursor position issue in headless Chrome — the Dojo editor sometimes appends text instead of prepending.

## Configuration

- `etc/db_connection_data.yml` — MySQL credentials (copy from `.sample`)
- `etc/pw_server.passwords` — Authentication credentials
- `etc/pw_server.salt` — Password salt
- `etc/api_tokens` — Bearer tokens for the `/api/videos` endpoint (one per line, `#` for comments). Generate with `bundle exec ruby bin/generate_api_token`. Read on every request (no restart needed). Never commit to git.
- `.yt-keys` — YouTube Data API v3 keys (one per line, `#` for comments). Used to display view counts on movie and short embeds. Supports multiple keys for different YouTube accounts. Keys are read from project root first, then `~/.yt-keys`. Falls back to `YOUTUBE_API_KEY` / `YOUTUBE_API_KEY_2` env vars. App works without keys (view counts simply not shown).

### YouTube video management (skill)

The `/api/videos` endpoint reference, the 4K migration/rebuild scripts in `bin/`, and the procedure for adding individual videos manually live in the `youtube-videos` skill (`.claude/skills/youtube-videos/SKILL.md`). Invoke it when adding videos, running rebuilds/imports, or working on the video API.

### YouTube Clips

YouTube Clips (artgroup `CLI`) are short segments clipped from existing videos. They use `youtube.com/clip/CLIP_ID` URLs (not regular watch URLs) so they play the clip segment, not the full video. Clips can't be iframe-embedded — they link directly to YouTube. Clip metadata is stored in `json/clips.json`, which provides the `CLIP_SOURCE_VIDEOS` mapping (clip ID → source video ID) used for thumbnail images. The clips feed (`https://www.youtube.com/feed/clips`) requires authentication — clip URLs must be extracted from the browser, then metadata fetched via `bin/import_clips --fetch`.

**Important**: `clips.json` must be read with `encoding: 'utf-8'` because the daemontools service runs without a UTF-8 locale (Ruby defaults to US-ASCII). The `ClipImage` view falls back to YouTube thumbnails (via source video ID) when no local image file exists.

`YoutubeHelper.clip_source_videos` caches the parsed `clips.json` in memory but reloads automatically when the file's mtime changes — so adding new clips doesn't require a service restart. If a clip's `source_video_id` lookup fails, the homepage grid silently drops the entry.