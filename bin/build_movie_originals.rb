#!/usr/bin/env ruby

# Build json/movie_originals.json — a mapping of @gozipa (Enhanced 4K) video IDs
# to their corresponding @jdavatz (original, non-4K) video IDs, matched by
# normalized title.
#
# Used at runtime by util/youtube_helper.rb so the movies page can show
# view/comment counts for both the 4K version and the original.
#
# Usage:
#   bundle exec ruby bin/build_movie_originals.rb

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'json'

YTDLP = ENV['YTDLP'] || 'yt-dlp'

GOZIPA_URLS = [
  'https://www.youtube.com/@gozipa/videos',
  'https://www.youtube.com/@gozipa/shorts',
]
JDAVATZ_URLS = [
  'https://www.youtube.com/@jdavatz/videos',
  'https://www.youtube.com/@jdavatz/shorts',
]

ytdlp_version = `#{YTDLP} --version 2>/dev/null`.strip
if ytdlp_version.empty?
  puts "ERROR: yt-dlp not found. Install with: pip3 install yt-dlp"
  exit 1
end
puts "Using yt-dlp #{ytdlp_version}"

def normalize_title(title)
  title.to_s.downcase
    .gsub(/\s*[\(\[]\s*enhanced\s+4k[^)\]]*[\)\]]\s*/i, '')
    .gsub(/\s*-?\s*enhanced\s+4k\s*v?\d*/i, '')
    .gsub(/\s*[\(\[]\s*4k[^)\]]*[\)\]]\s*/i, '')
    .gsub(/[^\w\s]/, '')
    .gsub(/\s+/, ' ')
    .strip
end

def fetch_channel(urls, label)
  videos = []
  seen = {}
  urls.each do |url|
    tab = url.include?('shorts') ? 'shorts' : 'videos'
    puts "  Fetching #{label} #{tab}: #{url}"
    count = 0
    IO.popen("#{YTDLP} --flat-playlist --dump-json #{url}", err: '/dev/null') do |io|
      io.each_line do |line|
        data = JSON.parse(line) rescue nil
        next unless data && data['id']
        next if seen[data['id']]
        seen[data['id']] = true
        videos << { id: data['id'], title: data['title'].to_s }
        count += 1
      end
    end
    puts "    -> #{count} videos"
  end
  videos
end

puts "\n=== Fetching @gozipa ==="
gozipa = fetch_channel(GOZIPA_URLS, '@gozipa')
puts "  -> #{gozipa.length} unique videos"

puts "\n=== Fetching @jdavatz ==="
jdavatz = fetch_channel(JDAVATZ_URLS, '@jdavatz')
puts "  -> #{jdavatz.length} unique videos"

# Index jdavatz by normalized title. If multiple jdavatz videos share a
# normalized title, keep the first — that's typically the older/original one.
jdavatz_by_key = {}
jdavatz.each do |v|
  key = normalize_title(v[:title])
  next if key.empty?
  jdavatz_by_key[key] ||= v
end

mapping = {}
unmatched = []
gozipa.each do |g|
  key = normalize_title(g[:title])
  match = jdavatz_by_key[key]
  if match
    mapping[g[:id]] = match[:id]
  else
    unmatched << g
  end
end

project_root = File.expand_path('..', File.dirname(__FILE__))
out_path = File.join(project_root, 'json', 'movie_originals.json')
File.write(out_path, JSON.pretty_generate(mapping))

puts "\n=== Result ==="
puts "  Matched:   #{mapping.length}"
puts "  Unmatched: #{unmatched.length} @gozipa videos with no @jdavatz counterpart"
puts "  Wrote:     #{out_path}"

if unmatched.any?
  puts "\n--- Unmatched @gozipa videos (no @jdavatz original found) ---"
  unmatched.first(20).each { |v| puts "  #{v[:id]}  #{v[:title]}" }
  puts "  ... and #{unmatched.length - 20} more" if unmatched.length > 20
end
