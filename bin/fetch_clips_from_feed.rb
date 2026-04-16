#!/usr/bin/env ruby

# Fetch clip metadata from authenticated YouTube /feed/clips pages.
#
# Usage:
#   bin/fetch_clips_from_feed.rb <cookies.txt> [<cookies.txt> ...]
#
# Merges results into json/clips.json (deduplicated by clip_id). Extracts
# clip_url, title, source_video_id, duration, and channel directly from
# the feed page's ytInitialData — no yt-dlp required.
#
# After running, apply to DB:
#   bundle exec ruby bin/import_clips --apply

require 'json'
require 'net/http'
require 'uri'

FEED_URL = 'https://www.youtube.com/feed/clips'
UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' \
     'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

def load_cookies(path)
  # Netscape HTTP Cookie File format:
  #   domain  TAB flag  TAB path  TAB secure  TAB expiration  TAB name  TAB value
  File.foreach(path).filter_map { |line|
    next if line.start_with?('#') || line.strip.empty?
    parts = line.chomp.split("\t")
    next unless parts.length >= 7
    "#{parts[5]}=#{parts[6]}"
  }.join('; ')
end

def fetch_feed(cookies_header)
  uri = URI(FEED_URL)
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  req['Cookie'] = cookies_header
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = 15
  http.read_timeout = 15
  res = http.request(req)
  res.body
end

def parse_duration(text)
  return 0 if text.nil? || text.empty?
  text.split(':').reduce(0) { |acc, p| acc * 60 + p.to_i }
end

def extract_clip(r)
  url_path = r.dig('navigationEndpoint', 'commandMetadata', 'webCommandMetadata', 'url').to_s
  return nil unless url_path.start_with?('/clip/')

  clip_id = url_path.sub('/clip/', '').split('?').first

  t = r['title'] || {}
  title = t['simpleText'] ||
          (t['runs'] || []).map { |run| run['text'] }.join

  source_video_id = ''
  (r.dig('thumbnail', 'thumbnails') || []).each do |th|
    if th['url'] =~ %r{/vi/([A-Za-z0-9_-]{11})/}
      source_video_id = Regexp.last_match(1)
      break
    end
  end

  duration = parse_duration(r.dig('lengthText', 'simpleText'))
  channel = (r.dig('ownerText', 'runs') || []).map { |run| run['text'] }.join

  {
    clip_id: clip_id,
    title: title,
    clip_url: "https://www.youtube.com/clip/#{clip_id}",
    source_video_id: source_video_id,
    duration: duration,
    channel: channel,
  }
end

def walk(obj, &block)
  case obj
  when Hash
    if (r = obj['gridVideoRenderer'])
      clip = extract_clip(r)
      block.call(clip) if clip
    end
    obj.each_value { |v| walk(v, &block) }
  when Array
    obj.each { |v| walk(v, &block) }
  end
end

def fetch(cookies_path)
  html = fetch_feed(load_cookies(cookies_path))
  m = html.match(/var ytInitialData = (\{.*?\});<\/script>/m)
  raise "ytInitialData not found in #{cookies_path} (cookies expired?)" unless m
  data = JSON.parse(m[1])
  clips = []
  walk(data) { |c| clips << c }
  clips
end

if ARGV.empty? || ARGV.include?('-h') || ARGV.include?('--help')
  puts File.read(__FILE__).lines[2..20].map { |l| l.sub(/^# ?/, '') }.join
  exit 1
end

project_root = File.expand_path('..', File.dirname(__FILE__))
out_path = File.join(project_root, 'json', 'clips.json')

existing = {}
if File.exist?(out_path)
  JSON.parse(File.read(out_path, encoding: 'utf-8'), symbolize_names: true).each do |c|
    existing[c[:clip_id]] = c
  end
end

added = 0
updated = 0
ARGV.each do |cookies|
  puts "Fetching with #{cookies}..."
  clips = fetch(cookies)
  puts "  Got #{clips.length} clips"
  clips.each do |clip|
    cid = clip[:clip_id]
    if existing[cid]
      if existing[cid] != clip
        existing[cid] = clip
        updated += 1
        puts "  UPDATED: #{clip[:title]}"
      end
    else
      existing[cid] = clip
      added += 1
      puts "  NEW:     #{clip[:title]}"
    end
  end
end

merged = existing.values.sort_by { |c| c[:title].to_s.downcase }
File.write(out_path, JSON.pretty_generate(merged))
puts "\nWrote #{merged.length} clips to #{out_path} (#{added} new, #{updated} updated)"
