#!/usr/bin/env ruby

# Submits davaz.com's sitemap to Google Search Console via the
# Search Console API v3 using a service-account JWT bearer flow.
# Also lists all currently-known sitemaps for the property so you
# can verify status (LastSubmitted, WarningCount, ErrorCount, ...).
#
# Prerequisites:
#   - Service account created in Google Cloud, JSON key stored at
#     etc/gsc_service_account.json (untracked; see .gitignore).
#   - Search Console API enabled in the SAME Google Cloud project as
#     the service account.
#   - Service-account email added as a user with Full permission on
#     the Search Console property for davaz.com.
#
# Usage:
#   bundle exec ruby bin/submit_sitemap.rb                # defaults below
#   bundle exec ruby bin/submit_sitemap.rb sc-domain:davaz.com
#   bundle exec ruby bin/submit_sitemap.rb https://davaz.com/ https://davaz.com/sitemap.xml
#
# Exits non-zero on any error so it's safe to wire into cron.

require 'base64'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

SERVICE_ACCOUNT_FILE = File.expand_path('../etc/gsc_service_account.json', __dir__)
SCOPE                = 'https://www.googleapis.com/auth/webmasters'
TOKEN_ENDPOINT       = 'https://oauth2.googleapis.com/token'
SC_API_BASE          = 'https://searchconsole.googleapis.com/webmasters/v3'

# Defaults: try URL-prefix property first; sitemap URL on the canonical host.
SITE_URL     = ARGV[0] || 'https://davaz.com/'
SITEMAP_URL  = ARGV[1] || 'https://davaz.com/sitemap.xml'

def base64url(bin)
  Base64.urlsafe_encode64(bin).delete('=')
end

def get_access_token(creds)
  now = Time.now.to_i
  header = { 'alg' => 'RS256', 'typ' => 'JWT' }
  claims = {
    'iss'   => creds['client_email'],
    'scope' => SCOPE,
    'aud'   => TOKEN_ENDPOINT,
    'iat'   => now,
    'exp'   => now + 3600
  }
  signing_input = "#{base64url(JSON.dump(header))}.#{base64url(JSON.dump(claims))}"
  key = OpenSSL::PKey::RSA.new(creds['private_key'])
  sig = key.sign(OpenSSL::Digest::SHA256.new, signing_input)
  jwt = "#{signing_input}.#{base64url(sig)}"

  res = Net::HTTP.post_form(URI(TOKEN_ENDPOINT),
    'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    'assertion'  => jwt)
  body = JSON.parse(res.body) rescue {}
  unless res.is_a?(Net::HTTPSuccess) && body['access_token']
    abort "OAuth token error: HTTP #{res.code}: #{res.body}"
  end
  body['access_token']
end

def request(method, path, token, body: nil)
  uri = URI("#{SC_API_BASE}#{path}")
  req = case method
        when :put then Net::HTTP::Put.new(uri)
        when :get then Net::HTTP::Get.new(uri)
        end
  req['Authorization'] = "Bearer #{token}"
  req['Content-Length'] = '0' if method == :put
  req.body = body if body
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
end

def submit_sitemap(token, site_url, sitemap_url)
  site = URI.encode_www_form_component(site_url)
  feed = URI.encode_www_form_component(sitemap_url)
  request(:put, "/sites/#{site}/sitemaps/#{feed}", token)
end

def list_sitemaps(token, site_url)
  site = URI.encode_www_form_component(site_url)
  request(:get, "/sites/#{site}/sitemaps", token)
end

unless File.exist?(SERVICE_ACCOUNT_FILE)
  abort "Service-account JSON not found at #{SERVICE_ACCOUNT_FILE}"
end
creds = JSON.parse(File.read(SERVICE_ACCOUNT_FILE))
puts "Service account: #{creds['client_email']}"
puts "Property:        #{SITE_URL}"
puts "Sitemap:         #{SITEMAP_URL}"
puts

token = get_access_token(creds)
puts "OAuth token acquired (#{token[0, 12]}...)"

res = submit_sitemap(token, SITE_URL, SITEMAP_URL)
puts "PUT sitemap: HTTP #{res.code}"
puts res.body unless res.code.to_i < 300

res = list_sitemaps(token, SITE_URL)
puts
puts "GET /sitemaps for #{SITE_URL} — HTTP #{res.code}"
if res.code.to_i < 300
  data = JSON.parse(res.body)
  (data['sitemap'] || []).each do |sm|
    puts "  #{sm['path']}"
    puts "    LastSubmitted: #{sm['lastSubmitted']}"
    puts "    LastDownloaded: #{sm['lastDownloaded']}"
    puts "    Errors: #{sm['errors']}  Warnings: #{sm['warnings']}"
    puts "    IsPending: #{sm['isPending']}  IsSitemapsIndex: #{sm['isSitemapsIndex']}"
  end
else
  puts res.body
end

abort "Sitemap submission failed" if res.code.to_i >= 300
