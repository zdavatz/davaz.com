# The [davaz.com](http://davaz.com/)

![davaz.com](https://raw.githubusercontent.com/zdavatz/davaz.com/master/doc/screenshot-davaz-com.png)

## Setup

### Requirements

* Ruby, `>= 3.4` (tested with 3.4.5)
* MySQL, `>= 5.6`
* `sudo apt-get install default-libmysqlclient-dev`
* ImageMagick
* [Git LFS](https://git-lfs.github.com/) (for database dumps in `db/`)
* Apache2 `a2enmod proxy_html`
* cronolog (optional)
* daemontools
* `sudo apt-get install daemontools-run`

### Install

```zsh
: Ruby and Rubygems
: check your ruby version
% ruby --version
ruby 3.4.5 (2025-07-16 revision 20cda200d3) [x86_64-linux]

% echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

% cd /var/www/new.davaz.com
% bundle install

: JavaScript libraries
% cd doc/resources
% curl -sLO https://download.dojotoolkit.org/release-1.7.12/dojo-release-1.7.12.tar.gz
% tar zxvf dojo-release-1.7.12.tar.gz
% mv dojo-release-1.7.12 dojo
```

### Configuration

Use sample files in `etc` directory.

```zsh
: Database (edit for your credentials)
% cp etc/db_connection_data.yml.sample etc/db_connection_data.yml

: Apache2 conf
% cp etc/davaz.com.conf.sample /etc/apache2/vhosts.d/davaz.com.conf

: Password for login
% cd /var/www/new.davaz.com
% echo "Salting" > etc/pw_server.salt # But use a different word!!
# To generate a user with a password (uses crypt() with the salt)
% bundle exec bin/generate_passwd_entry user@example.com mypassword >> etc/pw_server.passwords

: YouTube API keys for movie/short view counts (optional, one key per line)
% cat > .yt-keys <<EOF
# YouTube Data API v3 keys
YOUR_API_KEY_1
YOUR_API_KEY_2
EOF
```

### YouTube 4K Migration

All Movies (artgroup `MOV`) and Shorts (artgroup `SHO`) on davaz.com are sourced exclusively from the `@gozipa` YouTube channel (Enhanced 4K versions). The `@jdavatz` channel contains the original non-4K uploads.

#### Rebuild from @gozipa (full rebuild)

Deletes all MOV/SHO entries and recreates them from @gozipa's Videos and Shorts tabs, using YouTube titles and descriptions. Deduplicates by normalized title, preferring Enhanced 4K versions. Emojis are stripped (MySQL `utf8` limitation).

```zsh
: Requires yt-dlp
% pip3 install yt-dlp

: Dry run (shows what would change)
% bundle exec ruby bin/rebuild_movies_shorts_from_gozipa.rb

: Apply changes
% bundle exec ruby bin/rebuild_movies_shorts_from_gozipa.rb --apply
```

#### Incremental update (legacy)

Updates existing entries to 4K URLs and scans for missing videos:

```zsh
: Dry run (shows what would change)
% bundle exec ruby bin/update_4K_shorts_movies_yt.rb --scan

: Apply changes
% bundle exec ruby bin/update_4K_shorts_movies_yt.rb --scan --apply
```

Channels: `@jdavatz` (originals), `@gozipa` (Enhanced 4K). The rebuild script classifies videos from the Shorts tab or `<=60s` as `SHO`, longer ones as `MOV`. Individual manual additions use a finer-grained duration rule: `≤80s` → `CLI`, `81–240s` → `SHO`, `≥241s` → `MOV` (see "Adding individual videos manually" below). YouTube Clips created by Jürg are also stored as artgroup `CLI`. The rebuild script also fetches upload dates from YouTube API v3 (requires `.yt-keys`).

#### Adding individual videos manually

For adding individual Enhanced 4K videos without a full rebuild, fetch metadata via YouTube Data API v3 (`venv` + Python or Ruby), check for duplicates by video ID and normalized title, then insert via `db_manager.insert_artobject`. Always delete old non-4K duplicates after inserting the 4K replacement. No app restart needed — videos appear on next page load.

Classification by duration (individual additions only — the rebuild script keeps the legacy `<=60s → SHO, >60s → MOV` rule):

| Duration | artgroup_id |
|----------|-------------|
| ≤80s (≤1:20) | `CLI` |
| 81–240s (1:21–4:00) | `SHO` |
| ≥241s (≥4:01) | `MOV` |

### Adding YouTube Clips

YouTube Clips don't have a channel tab or API endpoint — they can only be listed from an authenticated browser session. The recommended workflow uses cookies exported from a logged-in Chrome session:

1. In Chrome, log in to the account (e.g. @gozipa). Install a cookie-export extension like "Get cookies.txt LOCALLY".
2. Visit `https://www.youtube.com`, click the extension → Export → save the Netscape-format file (e.g. `txt/gozipa.txt`).
3. Repeat for each account (e.g. `txt/jdavatz.txt`). **Never commit these files to git** — they grant full account access.
4. Upload to the server and run:

```zsh
: Merge clips from one or more authenticated accounts into json/clips.json
% bundle exec ruby bin/fetch_clips_from_feed.rb txt/gozipa.txt txt/jdavatz.txt

: Apply to DB (inserts new clips, updates renamed titles)
% bundle exec ruby bin/import_clips --apply
```

The fetcher extracts clip_url, title, source_video_id, and duration directly from the `/feed/clips` page's `ytInitialData` — no yt-dlp required. After running, invalidate the cookies by signing out all YouTube sessions for that account.

**Legacy workflow** (DevTools console + yt-dlp): see `bin/import_clips` header for the console snippet. Note: yt-dlp now requires cookies for clip extraction, so the feed-based fetcher above is simpler.

Clip metadata (including source video IDs for thumbnails) is stored in `json/clips.json`. The `CLIP_SOURCE_VIDEOS` mapping in `youtube_helper.rb` reads from this file at runtime — no hardcoded mappings. Note: `clips.json` is read with explicit UTF-8 encoding since the daemontools service runs without a locale.

### Homepage Video Grid

The homepage displays three separate sections of randomized YouTube video thumbnail grids: **Movies**, **Shorts**, and **Clips**. Each section has its own header and infinite scroll (10 initially, 10 more on scroll). Thumbnails load from YouTube's static CDN — no API quota is used. Videos open in a new tab. The order is reshuffled on every page reload. Private, blocked, or deleted videos are automatically hidden (detected client-side via thumbnail image dimensions).

A type-ahead **search bar** above the grids filters all three sections by title and description in real time. The bar has a prominent violet border so it stands out against the page, and its placeholder rotates through sample queries (e.g. `chick`, `Georgien`, `Kazakh`) to hint at searchable content. Above the bar, a **tag cloud** of the top ~40 keywords (extracted from video titles only, stopwords filtered) is rendered server-side; clicking a tag fills the search field and filters the grids. Curated tags can be added via `VideoSearchBar::PROMOTED_TAGS` in `src/view/personal/init.rb` — these appear in the cloud styled in gold to stand out, and find videos via the search's title-or-description match (e.g. `Prix de Bâle`, which only appears in descriptions). Promoted tags whose query matches no video at all are silently filtered out (`active_promoted_tags`), so every visible tag is guaranteed to surface at least one result. The remaining promoted (gold) tags are spread evenly across the violet derived tags rather than grouped together. A second curated list `PROMOTED_TAGS_VIOLET` exists for tags that should be styled like derived tags (violet, no gold accent) but couldn't be auto-derived — e.g. multi-word labels (`Male Mating`) or labels whose match comes from descriptions only. Same `[label, query]` format and same auto-filtering behaviour. Clearing the search restores the original grid layout with scroll-to-load.

### Clips Page

Clips have a dedicated listing page at `/en/works/clips/` (analogous to Movies and Shorts). Each clip shows a click-to-play YouTube embed, title, details, and a "More" link for the full art object detail view. Clips are stored with artgroup `CLI` in the database. Preview images fall back to YouTube thumbnails (via source video ID) when no local image is uploaded.

### Movies Page Sorting

The movies listing at `/en/works/movies/` shows each video with its YouTube view count and comment count. A sort bar at the top of the list lets you reorder videos client-side by **Default** (database order), **Most views**, or **Most comments**. Sorting is instant — no page reload — and uses `data-views` / `data-comments` attributes embedded on each movie's embed wrapper. View and comment counts are fetched together from the YouTube Data API v3 (`part=statistics`) and cached for 1 hour. The bar is styled in the page's gray-blue palette (`#738494` / `#d8dee4`) to match the existing top navigation.

When a 4K video has a known non-4K original on `@jdavatz`, the page renders a second stats line beneath the 4K line labelled "Original:" so the original's view/comment counts can be compared. The Original line is a link that opens the @jdavatz video on YouTube in a new tab. Sorting by views or comments uses the **aggregate** (4K + original) so videos with both versions rank fairly against single-version ones. The mapping lives in `json/movie_originals.json` (`{gozipa_id: jdavatz_id}`) and is built by:

```zsh
% bundle exec ruby bin/build_movie_originals.rb
```

The script fetches both channels via `yt-dlp --flat-playlist` and matches by normalized title (same rules as the rebuild script). Re-run it whenever new videos are added to either channel. The helper hot-reloads the JSON on mtime change — no service restart needed.

### Homepage Intro Text

The artist intro paragraph on the homepage is a heredoc in `src/util/lookandfeel.rb` (`intro_text`). It uses `<<~TEXT.gsub(/\n/, ' ').strip` so source-formatting newlines collapse to **spaces** (not empty string) — otherwise words from adjacent source lines glue together (`for\nthe` → `forthe`). Intentional line breaks inside the paragraph are written as explicit `<br>` tags.

### Database
* [Backup](https://github.com/zdavatz/davaz.com/tree/master/db)
* Dump DB: `mysqldump -u davaz -p -h localhost --databases davaz2 > davaz2_backup.sql`
* `# mysql -u root -h localhost -p`
* Create DB: `create database davaz2;`
* Grant DB rights: `grant all privileges on davaz2.* to davaz@localhost identified by 'password';`
* Flush: `flush privileges;`
* Restore DB: `mysql -u davaz -p -D davaz2 < migration_dump_2.12.2022.sql`

### Boot

[daemontools](http://cr.yp.to/daemontools.html) supervises the service.

* `cat /var/www/davaz.com/svc/run`
```zsh
#!/bin/sh
exec 2>&1
cd /var/www/davaz.com
exec setuidgid zdavatz /home/zdavatz/.rbenv/versions/3.4.5/bin/bundle exec rackup config.ru
```
* `cd /etc/service`
* `ln -s /var/www/davaz.com/svc/ davaz`

How to boot developer console.

```zsh
: Boot admin console
% bundle exec ./bin/admin
davaz> load_artgroups.length
-> 11
davaz> exit
-> Goodbye
```

## Test

### Dependencies

* Ruby `>= 3.4`
* Google Chrome or Firefox (for headless browser tests)
* [minitest](https://github.com/seattlerb/minitest)
* [Selenium WebDriver 4](https://www.selenium.dev/) (via [watir 7](https://github.com/watir/watir))

### Setup

```zsh
% git clone https://github.com/zdavatz/davaz.com.git
% cd davaz.com
% bundle install
```

Dojo toolkit is downloaded automatically on first test run.

### How to run

#### Test suite

```zsh
% bundle exec rake test
```

#### Single test method

```zsh
% bundle exec rake test TEST_OPTS="--name=TestLectures#test_lectures_toggle_hidden_dev_links"
```

### Current status

27 runs, 159 assertions, 0 failures, 0 errors, 5 skips (Ruby 3.4.5, headless Chrome).
Note: The admin movies WYSIWYG editor test has a known flaky cursor position issue in headless Chrome.

# TODO:

* Fix 5 skipped tests:
  * Stub of db_manager does not allow creation/update of art_objects
  * Shop does not show some help messages on validation failures
  * Movies: thumbnail of movie picture is not shown while running tests
  * Postal code validation message not shown
* Improve/add coverage for partial views

## License

Copyright (C) 2006-2016 ywesee GmbH.

This is free software;
You can redistribute it and/or modify it under the terms of the GNU General Public License (GPL v2.0).

See `LICENSE`.
