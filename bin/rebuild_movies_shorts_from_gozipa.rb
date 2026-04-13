#!/usr/bin/env ruby

# Rebuild all Movies (MOV) and Shorts (SHO) DB entries from the @gozipa
# YouTube channel (Enhanced 4K versions only).
#
# This script:
#   1. Fetches all videos from @gozipa via yt-dlp (--flat-playlist for speed)
#   2. Fetches full metadata (title, description) for each video via yt-dlp
#   3. Classifies: <=60s -> SHO, >60s -> MOV
#   4. Deletes all existing MOV/SHO entries from the DB
#   5. Inserts new entries with YouTube title + description
#
# Usage:
#   bundle exec ruby bin/rebuild_movies_shorts_from_gozipa.rb            # dry run
#   bundle exec ruby bin/rebuild_movies_shorts_from_gozipa.rb --apply    # apply changes

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'json'
require 'open3'
require 'util/config'
require 'util/db_manager'

DRY_RUN = !ARGV.include?('--apply')
YTDLP = ENV['YTDLP'] || 'yt-dlp'
GOZIPA_VIDEOS_URL = 'https://www.youtube.com/@gozipa/videos'
GOZIPA_SHORTS_URL = 'https://www.youtube.com/@gozipa/shorts'

if DRY_RUN
  puts "=== DRY RUN (pass --apply to make changes) ===\n\n"
else
  puts "=== APPLYING CHANGES ===\n\n"
end

# Verify yt-dlp
ytdlp_version = `#{YTDLP} --version 2>/dev/null`.strip
if ytdlp_version.empty?
  puts "ERROR: yt-dlp not found. Install with: pip3 install yt-dlp"
  exit 1
end
puts "Using yt-dlp #{ytdlp_version}\n\n"

db = DaVaz::Util::DbManager.new

# --- Step 1: Fetch @gozipa video catalog ---

puts "=== Step 1: Fetching @gozipa video catalog ===\n"
videos = []
seen_ids = {}

[GOZIPA_VIDEOS_URL, GOZIPA_SHORTS_URL].each do |url|
  tab = url.include?('shorts') ? 'Shorts' : 'Videos'
  puts "  Fetching #{tab} tab: #{url}"
  count = 0
  IO.popen("#{YTDLP} --flat-playlist --dump-json #{url}", err: '/dev/null') do |io|
    io.each_line do |line|
      data = JSON.parse(line)
      id = data['id']
      next if seen_ids[id]  # skip duplicates across tabs
      seen_ids[id] = true
      videos << {
        video_id: id,
        title: data['title'] || '',
        description: data['description'] || '',
        duration: (data['duration'] || 0).to_i,
        from_shorts_tab: tab == 'Shorts'
      }
      count += 1
    end
  end
  puts "    -> #{count} new videos from #{tab} tab"
end
puts "  -> #{videos.length} total unique videos on @gozipa\n\n"

# --- Step 1b: Deduplicate — prefer Enhanced 4K versions ---

def normalize_title(title)
  title.to_s.downcase
    .gsub(/\s*[\(\[]\s*enhanced\s+4k[^)\]]*[\)\]]\s*/i, '')
    .gsub(/\s*-?\s*enhanced\s+4k\s*v?\d*/i, '')
    .gsub(/\s*[\(\[]\s*4k[^)\]]*[\)\]]\s*/i, '')
    .gsub(/[^\w\s]/, '')
    .gsub(/\s+/, ' ')
    .strip
end

# Group by normalized title, prefer the "Enhanced 4K" version
by_title = {}
videos.each do |v|
  key = normalize_title(v[:title])
  existing = by_title[key]
  if existing.nil?
    by_title[key] = v
  elsif v[:title] =~ /4k/i && !(existing[:title] =~ /4k/i)
    # Prefer the 4K version
    by_title[key] = v
  elsif v[:title] =~ /4k/i && existing[:title] =~ /4k/i
    # Both are 4K — prefer newer version (v2, v3, etc.) or longer title
    if v[:title] =~ /v(\d+)/ && existing[:title] =~ /v(\d+)/
      by_title[key] = v if v[:title].match(/v(\d+)/)[1].to_i > existing[:title].match(/v(\d+)/)[1].to_i
    end
  end
end

deduped = by_title.values
puts "=== Step 1b: Deduplication ==="
puts "  Before: #{videos.length} videos"
puts "  After:  #{deduped.length} unique titles (preferring Enhanced 4K)\n\n"

# --- Step 2: Classify into MOV and SHO ---
# Videos from the Shorts tab are SHO, or if duration known and <=60s.
# Everything else is MOV.

shorts = deduped.select { |v|
  v[:from_shorts_tab] || (v[:duration] > 0 && v[:duration] <= 60)
}
movies = deduped.reject { |v|
  v[:from_shorts_tab] || (v[:duration] > 0 && v[:duration] <= 60)
}

puts "=== Step 2: Classification ==="
puts "  Shorts (<=60s): #{shorts.length}"
puts "  Movies (>60s):  #{movies.length}\n\n"

# --- Step 3: Show what will change ---

puts "=== Step 3: Current DB state ==="
conn = db.send(:connection)
current_mov = conn.query("SELECT COUNT(*) as c FROM artobjects WHERE artgroup_id = 'MOV'").first['c']
current_sho = conn.query("SELECT COUNT(*) as c FROM artobjects WHERE artgroup_id = 'SHO'").first['c']
current_tags = conn.query(
  "SELECT COUNT(*) as c FROM tags_artobjects ta " \
  "JOIN artobjects a ON ta.artobject_id = a.artobject_id " \
  "WHERE a.artgroup_id IN ('MOV', 'SHO')"
).first['c']

puts "  Current MOV entries: #{current_mov}"
puts "  Current SHO entries: #{current_sho}"
puts "  Current tag associations: #{current_tags}"
puts ""
puts "  Will replace with:"
puts "    #{movies.length} MOV entries (from @gozipa)"
puts "    #{shorts.length} SHO entries (from @gozipa)"
puts ""

def format_duration(seconds)
  if seconds >= 3600
    "%d:%02d:%02d" % [seconds / 3600, (seconds % 3600) / 60, seconds % 60]
  else
    "%d:%02d" % [seconds / 60, seconds % 60]
  end
end

# Print sample entries
puts "--- Sample new MOV entries ---"
movies.first(5).each do |v|
  puts "  [#{format_duration(v[:duration])}] #{v[:title]}"
end
puts "  ... and #{movies.length - 5} more" if movies.length > 5
puts ""

puts "--- Sample new SHO entries ---"
shorts.first(5).each do |v|
  puts "  [#{format_duration(v[:duration])}] #{v[:title]}"
end
puts "  ... and #{shorts.length - 5} more" if shorts.length > 5
puts ""

if DRY_RUN
  puts "=== DRY RUN complete. Pass --apply to make changes. ===\n"
  puts "\nFull list of new entries:\n\n"
  puts "--- MOVIES (#{movies.length}) ---"
  movies.sort_by { |v| v[:title] }.each do |v|
    desc_preview = v[:description].to_s.gsub("\n", ' ')[0..80]
    puts "  MOV [#{format_duration(v[:duration])}] #{v[:title]}"
    puts "      URL: https://www.youtube.com/watch?v=#{v[:video_id]}"
    puts "      Desc: #{desc_preview}..." unless desc_preview.strip.empty?
  end
  puts "\n--- SHORTS (#{shorts.length}) ---"
  shorts.sort_by { |v| v[:title] }.each do |v|
    desc_preview = v[:description].to_s.gsub("\n", ' ')[0..80]
    puts "  SHO [#{format_duration(v[:duration])}] #{v[:title]}"
    puts "      URL: https://www.youtube.com/watch?v=#{v[:video_id]}"
    puts "      Desc: #{desc_preview}..." unless desc_preview.strip.empty?
  end
  exit 0
end

# --- Step 4: Delete existing MOV/SHO entries ---

puts "=== Step 4: Deleting existing MOV/SHO entries ===\n"

# Get all existing MOV/SHO artobject_ids
existing = conn.query(
  "SELECT artobject_id FROM artobjects WHERE artgroup_id IN ('MOV', 'SHO')"
).map { |r| r['artobject_id'] }

puts "  Deleting #{existing.length} entries..."

# Delete in batches using the db_manager's delete method (handles tags/links)
deleted = 0
existing.each do |id|
  db.delete_artobject(id)
  deleted += 1
  print "." if deleted % 50 == 0
end
puts "\n  Deleted #{deleted} entries.\n\n"

# --- Step 5: Insert new entries from @gozipa ---

puts "=== Step 5: Inserting new entries from @gozipa ===\n"

created_mov = 0
created_sho = 0

all_entries = movies.map { |v| [v, 'MOV'] } + shorts.map { |v| [v, 'SHO'] }

# Strip 4-byte UTF-8 characters (emojis) that MySQL utf8 can't handle
def strip_emojis(str)
  str.to_s.encode('UTF-8', invalid: :replace, undef: :replace)
    .gsub(/[\u{10000}-\u{10FFFF}]/, '')
    .gsub(/[\u{FE00}-\u{FE0F}]/, '')     # variation selectors
    .gsub(/[\u{200D}]/, '')               # zero-width joiner
    .gsub(/[\u{20E3}]/, '')               # combining enclosing keycap
    .gsub(/[\u{1F000}-\u{1FFFF}]/, '')    # supplementary symbols
    .gsub(/\s+/, ' ')
    .strip
end

all_entries.each do |video, artgroup|
  url = "https://www.youtube.com/watch?v=#{video[:video_id]}"
  description = strip_emojis(video[:description].to_s[0..2000])
  title = strip_emojis(video[:title].to_s)

  artobject_id = db.insert_artobject({
    artgroup_id: artgroup,
    title: title,
    text: description,
    url: url,
    movie_type: 'original'
  })

  if artgroup == 'MOV'
    created_mov += 1
  else
    created_sho += 1
  end

  print "." if (created_mov + created_sho) % 50 == 0
end

puts "\n\n"

# --- Step 6: Fetch upload dates from YouTube API ---

puts "=== Step 6: Fetching upload dates from YouTube API ===\n"

api_keys = DaVaz::Util::YoutubeHelper.api_keys rescue []
if api_keys.empty?
  puts "  No API keys found (.yt-keys), skipping date fetch."
else
  conn = db.send(:connection)
  rows = conn.query(
    "SELECT artobject_id, url FROM artobjects " \
    "WHERE artgroup_id IN ('MOV', 'SHO') AND date = '1901-01-01'"
  )
  entries = rows.map { |r|
    vid = r['url'][/(?:youtube\.com\/watch\?.*v=|youtu\.be\/)([A-Za-z0-9_-]{11})/, 1]
    { id: r['artobject_id'], vid: vid } if vid
  }.compact

  api_key = api_keys.first
  updated_dates = 0
  entries.each_slice(50) do |batch|
    ids = batch.map { |e| e[:vid] }.join(',')
    uri = URI("https://www.googleapis.com/youtube/v3/videos?part=snippet&id=#{ids}&key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5
    response = http.get(uri.request_uri)
    data = JSON.parse(response.body)
    dates = {}
    (data['items'] || []).each do |item|
      pub = item.dig('snippet', 'publishedAt')
      dates[item['id']] = pub[0..9] if pub
    end
    batch.each do |e|
      date = dates[e[:vid]]
      next unless date
      conn.query("UPDATE artobjects SET date = '#{date}' WHERE artobject_id = #{e[:id]}")
      updated_dates += 1
    end
  rescue StandardError => e
    puts "  API error: #{e.message}"
  end
  puts "  Updated #{updated_dates} entries with upload dates.\n"
end

puts "=== Done! ==="
puts "  Created #{created_mov} MOV entries"
puts "  Created #{created_sho} SHO entries"
puts "  Total: #{created_mov + created_sho}"
