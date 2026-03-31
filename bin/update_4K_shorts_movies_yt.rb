#!/usr/bin/env ruby

# Script to update YouTube Shorts/Movies URLs to 4K and create missing entries.
# Uses yt-dlp (no API quota limits).
#
# Channels:
#   @jdavatz (UCc7N7gI1hKpqQmVan11-vCQ) — original videos
#   @gozipa  (UCnZkKjCsLInopdskNc_hGLg) — Enhanced 4K versions
#
# Operations:
#   1. Update existing Shorts URLs to their 4K versions from @gozipa
#   2. Update existing Movies URLs to their 4K versions from @gozipa
#   3. Scan @jdavatz for videos not in the DB and create them:
#      - YouTube Shorts (<=60s) -> artgroup 'SHO' (davaz.com/works/shorts/)
#      - Longer videos (>60s)   -> artgroup 'MOV' (davaz.com/works/movies/)
#      - Uses 4K URL from @gozipa if available
#
# Usage:
#   bundle exec ruby bin/update_4K_shorts_movies_yt.rb                # dry run, update existing only
#   bundle exec ruby bin/update_4K_shorts_movies_yt.rb --scan         # also scan @jdavatz for missing
#   bundle exec ruby bin/update_4K_shorts_movies_yt.rb --apply        # apply changes
#   bundle exec ruby bin/update_4K_shorts_movies_yt.rb --scan --apply # scan + apply

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'json'
require 'set'
require 'open3'
require 'util/config'
require 'util/db_manager'
require 'util/youtube_helper'

DRY_RUN = !ARGV.include?('--apply')
SCAN_CHANNEL = ARGV.include?('--scan')

YTDLP = ENV['YTDLP'] || 'yt-dlp'

JDAVATZ_CHANNEL_URL = 'https://www.youtube.com/@jdavatz/videos'
GOZIPA_CHANNEL_URL  = 'https://www.youtube.com/@gozipa/videos'

if DRY_RUN
  puts "=== DRY RUN (pass --apply to make changes) ===\n\n"
else
  puts "=== APPLYING CHANGES ===\n\n"
end

# Verify yt-dlp is available
ytdlp_version = `#{YTDLP} --version 2>/dev/null`.strip
if ytdlp_version.empty?
  puts "ERROR: yt-dlp not found. Install with: pip3 install yt-dlp"
  exit 1
end
puts "Using yt-dlp #{ytdlp_version}\n\n"

db = DaVaz::Util::DbManager.new

# --- yt-dlp helpers ---

# Fetch all videos from a channel using --flat-playlist (fast, no cookies needed)
def fetch_channel_videos(channel_url)
  puts "Fetching videos from #{channel_url} ..."
  videos = []
  cmd = "#{YTDLP} --flat-playlist --dump-json #{channel_url}"
  IO.popen(cmd, err: '/dev/null') do |io|
    io.each_line do |line|
      data = JSON.parse(line)
      videos << {
        video_id: data['id'],
        title: data['title'],
        description: data['description'] || '',
        duration: (data['duration'] || 0).to_i
      }
    end
  end
  puts "  -> #{videos.length} videos found"
  videos
end

# Build a lookup by normalized title for fuzzy matching
def normalize_title(title)
  title.to_s.downcase
    .gsub(/\s*[\(\[]\s*enhanced\s+4k[^)\]]*[\)\]]\s*/i, '')
    .gsub(/\s*-?\s*enhanced\s+4k\s*/i, '')
    .gsub(/\s*[\(\[]\s*4k[^)\]]*[\)\]]\s*/i, '')
    .gsub(/[^\w\s]/, '')
    .gsub(/\s+/, ' ')
    .strip
end

def format_duration(seconds)
  if seconds >= 3600
    "%d:%02d:%02d" % [seconds / 3600, (seconds % 3600) / 60, seconds % 60]
  else
    "%d:%02d" % [seconds / 60, seconds % 60]
  end
end

# --- Load @gozipa 4K videos and build lookup ---

puts "=== Loading @gozipa 4K catalog ===\n"
gozipa_videos = fetch_channel_videos(GOZIPA_CHANNEL_URL)

# Build lookup: normalized_title -> gozipa video (prefer "Enhanced 4K" in title)
gozipa_by_title = {}
gozipa_videos.each do |v|
  key = normalize_title(v[:title])
  # Prefer videos with "4K" in the title
  existing = gozipa_by_title[key]
  if existing.nil? || (v[:title] =~ /4k/i && !(existing[:title] =~ /4k/i))
    gozipa_by_title[key] = v
  end
end
puts "  -> #{gozipa_by_title.length} unique titles indexed\n\n"

# Find 4K match for a given title
def find_4k_match(title, gozipa_by_title)
  key = normalize_title(title)
  return gozipa_by_title[key] if gozipa_by_title[key]

  # Try partial matching
  gozipa_by_title.each do |gkey, video|
    next if gkey.length < 5
    if key.include?(gkey) || gkey.include?(key)
      return video
    end
  end
  nil
end

# --- Load existing DB entries ---

shorts = db.load_shorts
movies = db.load_movies
puts "Found #{shorts.length} shorts and #{movies.length} movies in database\n\n"

# Build set of ALL existing video IDs
existing_video_ids = Set.new
(shorts + movies).each do |obj|
  vid = DaVaz::Util::YoutubeHelper.extract_video_id(obj.url)
  existing_video_ids << vid if vid
end

# Also track gozipa video IDs that are already in the DB
gozipa_ids_in_db = Set.new
gozipa_videos.each do |gv|
  existing_video_ids.each do |ev|
    gozipa_ids_in_db << gv[:video_id] if ev == gv[:video_id]
  end
end

# --- Step 1: Fix entries with YouTube URL in text but not in url field ---

url_fixed = 0
(shorts + movies).each do |obj|
  video_id = DaVaz::Util::YoutubeHelper.extract_video_id(obj.url)
  next if video_id

  text_match = obj.text.to_s.match(%r{youtube\.com/watch\?v=([A-Za-z0-9_-]{11})})
  next unless text_match

  video_id = text_match[1]
  extracted_url = "https://www.youtube.com/watch?v=#{video_id}"
  puts "FIX URL: #{obj.artobject_id}: #{obj.title}"
  puts "         Found in text field: #{extracted_url}"
  unless DRY_RUN
    db.update_artobject(obj.artobject_id, { url: extracted_url })
    obj.url = extracted_url
    puts "         FIXED!"
  end
  existing_video_ids << video_id
  url_fixed += 1
end

puts "\nFixed #{url_fixed} URLs from text field\n" if url_fixed > 0

# --- Step 2: Update existing Shorts to 4K versions from @gozipa ---

puts "\n=== Step 2: Update existing Shorts to 4K ===\n\n"

updated_shorts = 0
skipped_shorts = 0

shorts.each do |short|
  video_id = DaVaz::Util::YoutubeHelper.extract_video_id(short.url)
  unless video_id
    skipped_shorts += 1
    next
  end

  # Already a gozipa video?
  is_gozipa = gozipa_videos.any? { |gv| gv[:video_id] == video_id }
  if is_gozipa
    skipped_shorts += 1
    next
  end

  # Find 4K match by title
  match = find_4k_match(short.title, gozipa_by_title)
  if match
    new_url = "https://www.youtube.com/watch?v=#{match[:video_id]}"
    puts "#{short.artobject_id}: #{short.title}"
    puts "       Old: #{short.url}"
    puts "       New: #{new_url} (#{match[:title]})"
    unless DRY_RUN
      db.update_artobject(short.artobject_id, { url: new_url })
      puts "       UPDATED!"
    end
    existing_video_ids << match[:video_id]
    updated_shorts += 1
  else
    skipped_shorts += 1
  end
end

puts "\n--- Shorts Summary ---"
puts "Total:    #{shorts.length}"
puts "Updated:  #{updated_shorts}" if updated_shorts > 0
puts "Skipped:  #{skipped_shorts}" if skipped_shorts > 0

# --- Step 3: Update existing Movies to 4K versions from @gozipa ---

puts "\n=== Step 3: Update existing Movies to 4K ===\n\n"

updated_movies = 0
skipped_movies = 0

movies.each do |movie|
  video_id = DaVaz::Util::YoutubeHelper.extract_video_id(movie.url)
  unless video_id
    skipped_movies += 1
    next
  end

  is_gozipa = gozipa_videos.any? { |gv| gv[:video_id] == video_id }
  if is_gozipa
    skipped_movies += 1
    next
  end

  match = find_4k_match(movie.title, gozipa_by_title)
  if match
    new_url = "https://www.youtube.com/watch?v=#{match[:video_id]}"
    puts "#{movie.artobject_id}: #{movie.title}"
    puts "       Old: #{movie.url}"
    puts "       New: #{new_url} (#{match[:title]})"
    unless DRY_RUN
      db.update_artobject(movie.artobject_id, { url: new_url })
      puts "       UPDATED!"
    end
    existing_video_ids << match[:video_id]
    updated_movies += 1
  else
    skipped_movies += 1
  end
end

puts "\n--- Movies Summary ---"
puts "Total:    #{movies.length}"
puts "Updated:  #{updated_movies}" if updated_movies > 0
puts "Skipped:  #{skipped_movies}" if skipped_movies > 0

# --- Step 4: Scan @jdavatz for missing videos ---

if SCAN_CHANNEL
  puts "\n\n=== Step 4: Scan @jdavatz for missing videos ==="

  jdavatz_videos = fetch_channel_videos(JDAVATZ_CHANNEL_URL)

  # Also add gozipa IDs to existing set (don't duplicate those either)
  gozipa_videos.each { |gv| existing_video_ids << gv[:video_id] if gozipa_ids_in_db.include?(gv[:video_id]) }

  missing = jdavatz_videos.reject { |v| existing_video_ids.include?(v[:video_id]) }

  # Also reject if a 4K version of this video is already in the DB
  missing.reject! do |v|
    match = find_4k_match(v[:title], gozipa_by_title)
    match && existing_video_ids.include?(match[:video_id])
  end

  puts "\nKnown video IDs in DB: #{existing_video_ids.length}"
  puts "Videos on @jdavatz:    #{jdavatz_videos.length}"
  puts "Missing from DB:       #{missing.length}\n\n"

  new_shorts = missing.select { |v| v[:duration] > 0 && v[:duration] <= 60 }
  new_movies = missing.select { |v| v[:duration] == 0 || v[:duration] > 60 }

  puts "  -> #{new_shorts.length} Shorts (<=60s) -> davaz.com/works/shorts/"
  puts "  -> #{new_movies.length} Movies (>60s)  -> davaz.com/works/movies/"
  puts ""

  created_shorts = 0
  created_movies = 0

  # Create missing Shorts
  if new_shorts.any?
    puts "--- New Shorts ---\n\n"
    new_shorts.each do |video|
      match = find_4k_match(video[:title], gozipa_by_title)
      if match
        use_url = "https://www.youtube.com/watch?v=#{match[:video_id]}"
        use_description = match[:description]
        puts "SHO (4K) [#{format_duration(video[:duration])}]: #{video[:title]}"
        puts "         4K: #{use_url}"
      else
        use_url = "https://www.youtube.com/watch?v=#{video[:video_id]}"
        use_description = video[:description]
        puts "SHO      [#{format_duration(video[:duration])}]: #{video[:title]}"
        puts "         URL: #{use_url}"
      end

      use_description = use_description.to_s[0..2000]
      desc_preview = use_description.gsub("\n", ' ')[0..100]
      puts "         Description: #{desc_preview}..." unless desc_preview.strip.empty?

      unless DRY_RUN
        artobject_id = db.insert_artobject({
          artgroup_id: 'SHO',
          title: video[:title].to_s,
          text: use_description,
          url: use_url,
          movie_type: 'original'
        })
        puts "         CREATED! (artobject_id: #{artobject_id})"
      end
      created_shorts += 1
      puts ""
    end
  end

  # Create missing Movies
  if new_movies.any?
    puts "--- New Movies ---\n\n"
    new_movies.each do |video|
      match = find_4k_match(video[:title], gozipa_by_title)
      if match
        use_url = "https://www.youtube.com/watch?v=#{match[:video_id]}"
        use_description = match[:description]
        puts "MOV (4K) [#{format_duration(video[:duration])}]: #{video[:title]}"
        puts "         4K: #{use_url}"
      else
        use_url = "https://www.youtube.com/watch?v=#{video[:video_id]}"
        use_description = video[:description]
        puts "MOV      [#{format_duration(video[:duration])}]: #{video[:title]}"
        puts "         URL: #{use_url}"
      end

      use_description = use_description.to_s[0..2000]
      desc_preview = use_description.gsub("\n", ' ')[0..100]
      puts "         Description: #{desc_preview}..." unless desc_preview.strip.empty?

      unless DRY_RUN
        artobject_id = db.insert_artobject({
          artgroup_id: 'MOV',
          title: video[:title].to_s,
          text: use_description,
          url: use_url,
          movie_type: 'original'
        })
        puts "         CREATED! (artobject_id: #{artobject_id})"
      end
      created_movies += 1
      puts ""
    end
  end

  puts "--- Step 4 Summary ---"
  if DRY_RUN
    puts "Would create Shorts: #{created_shorts}"
    puts "Would create Movies: #{created_movies}"
  else
    puts "Created Shorts:      #{created_shorts}"
    puts "Created Movies:      #{created_movies}"
  end
end

puts "\n"
puts "Run with --apply to make changes." if DRY_RUN
