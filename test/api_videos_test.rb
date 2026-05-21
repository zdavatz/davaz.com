require 'minitest/autorun'
require 'rack/mock'
require 'json'
require 'tempfile'
require 'pathname'

root_dir = Pathname.new(__FILE__).parent.parent.expand_path
$LOAD_PATH.unshift(root_dir.join('src').to_s)
require 'davaz'
require 'util/config'
require 'support/override_config'
require 'util/api_videos'

class FakeDbManager
  attr_reader :inserted, :existing
  def initialize(existing: {})
    @inserted = []
    @existing = existing
    @next_id = 9000
  end

  def insert_artobject(values)
    id = (@next_id += 1)
    @inserted << values.merge(artobject_id: id)
    id
  end

  # Mimics DbManager#connection — yields an object that responds to #query.
  # Stubbed query supports the existing-id lookup used in ApiVideos.
  def send(sym, &block)
    if sym == :connection
      block.call(self)
    else
      super
    end
  end

  def query(sql)
    if sql =~ /url LIKE '%(.+)%'/
      vid = Regexp.last_match(1)
      rows = @existing.key?(vid) ? [{ 'artobject_id' => @existing[vid] }] : []
      FakeResult.new(rows)
    else
      FakeResult.new([])
    end
  end

  def escape(str)
    str.to_s.gsub("'", "\\'")
  end

  class FakeResult
    def initialize(rows); @rows = rows; end
    def to_a; @rows; end
  end
end

class TestApiVideos < Minitest::Test
  def setup
    @tokens_file = Tempfile.new(['api_tokens', ''])
    @tokens_file.write("# comment\nsecrettoken123\n")
    @tokens_file.close

    @tags_file = Tempfile.new(['promoted_tags', '.json'])
    @tags_file.write(JSON.pretty_generate(
      'promoted'        => [],
      'promoted_violet' => [],
      'promoted_red'    => []) + "\n")
    @tags_file.close

    @db = FakeDbManager.new
    inner = ->(_env) { [200, { 'content-type' => 'text/plain' }, ['fallthrough']] }
    @middleware = DaVaz::Util::ApiVideos.new(
      inner, db_manager: @db,
      tokens_file: @tokens_file.path,
      tags_file: @tags_file.path)
    @mock = Rack::MockRequest.new(@middleware)

    # Stub YouTube metadata to avoid network calls. Description has no
    # leading color word so sniffing is a no-op for the default tests.
    @middleware.define_singleton_method(:fetch_metadata) do |video_id|
      {
        title: "Sample for #{video_id}",
        description: "Original: https://youtube.com/watch?v=other",
        seconds: 42,
        published_on: '2026-05-08'
      }
    end
  end

  def teardown
    @tokens_file.unlink
    @tags_file.unlink
  end

  def read_tags
    JSON.parse(File.read(@tags_file.path, encoding: 'utf-8'))
  end

  def test_passes_through_non_api_paths
    res = @mock.get('/en/personal/init/')
    assert_equal 200, res.status
    assert_equal 'fallthrough', res.body
  end

  def test_get_on_api_path_returns_405
    res = @mock.get('/api/videos', 'HTTP_AUTHORIZATION' => 'Bearer secrettoken123')
    assert_equal 405, res.status
  end

  def test_unauthorized_without_token
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk' }, auth: nil)
    assert_equal 401, res.status
    assert_match(/unauthorized/, res.body)
  end

  def test_unauthorized_with_wrong_token
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk' }, auth: 'wrong')
    assert_equal 401, res.status
  end

  def test_rejects_missing_url
    res = post_json({}, auth: 'secrettoken123')
    assert_equal 422, res.status
    assert_match(/missing url/, res.body)
  end

  def test_rejects_unrecognized_url
    res = post_json({ url: 'https://example.com/foo' }, auth: 'secrettoken123')
    assert_equal 422, res.status
  end

  def test_rejects_invalid_json
    res = @mock.post('/api/videos',
      'HTTP_AUTHORIZATION' => 'Bearer secrettoken123',
      'CONTENT_TYPE' => 'application/json',
      input: '{not json')
    assert_equal 400, res.status
  end

  def test_inserts_and_classifies_short_as_cli
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk' },
                    auth: 'secrettoken123')
    assert_equal 201, res.status
    body = JSON.parse(res.body)
    assert_equal 'CLI', body['artgroup_id']
    assert_equal 9001, body['id']
    assert_equal 1, @db.inserted.size
    assert_equal 'CLI', @db.inserted.first[:artgroup_id]
    assert_equal 'Sample for abcdefghijk', @db.inserted.first[:title]
    assert_equal '2026-05-08', @db.inserted.first[:date]
  end

  def test_classifies_by_duration
    {120 => 'SHO', 300 => 'MOV', 80 => 'CLI', 81 => 'SHO', 240 => 'SHO', 241 => 'MOV'}.each do |secs, expected|
      @middleware.define_singleton_method(:fetch_metadata) do |vid|
        { title: "vid#{vid}", description: '', seconds: secs, published_on: '2026-05-08' }
      end
      res = post_json({ url: "https://www.youtube.com/watch?v=vid#{secs.to_s.rjust(8, '0')}" },
                      auth: 'secrettoken123')
      assert_equal 201, res.status, "duration #{secs} should produce 201"
      assert_equal expected, JSON.parse(res.body)['artgroup_id'], "duration #{secs} should be #{expected}"
    end
  end

  def test_explicit_tag_color_red_appends_to_promoted_red
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk',
                      tag_color: 'red' }, auth: 'secrettoken123')
    assert_equal 201, res.status
    body = JSON.parse(res.body)
    assert_equal({ 'bucket' => 'promoted_red', 'label' => 'Sample for abcdefghijk' },
                 body['tag_added'])
    tags = read_tags
    assert_equal [['Sample for abcdefghijk', 'sample for abcdefghijk']],
                 tags['promoted_red']
    assert_empty tags['promoted']
    assert_empty tags['promoted_violet']
  end

  def test_unknown_tag_color_falls_through_to_sniff
    @middleware.define_singleton_method(:fetch_metadata) do |vid|
      { title: "vid#{vid}", description: 'red',
        seconds: 30, published_on: '2026-05-08' }
    end
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk',
                      tag_color: 'taupe' }, auth: 'secrettoken123')
    assert_equal 201, res.status
    assert_equal 'promoted_red', JSON.parse(res.body).dig('tag_added', 'bucket')
  end

  def test_sniff_picks_red_from_description_first_word
    @middleware.define_singleton_method(:fetch_metadata) do |vid|
      { title: "Title#{vid}", description: "red\n\nOriginal: ...",
        seconds: 30, published_on: '2026-05-08' }
    end
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk' },
                    auth: 'secrettoken123')
    assert_equal 201, res.status
    assert_equal 'promoted_red', JSON.parse(res.body).dig('tag_added', 'bucket')
  end

  def test_sniff_picks_yellow_purple_red
    %w[yellow purple red].each do |color|
      @tags_file = Tempfile.new(['promoted_tags', '.json'])
      @tags_file.write(JSON.pretty_generate(
        'promoted' => [], 'promoted_violet' => [], 'promoted_red' => []) + "\n")
      @tags_file.close
      @db = FakeDbManager.new
      inner = ->(_env) { [200, {}, []] }
      @middleware = DaVaz::Util::ApiVideos.new(
        inner, db_manager: @db,
        tokens_file: @tokens_file.path, tags_file: @tags_file.path)
      @middleware.define_singleton_method(:fetch_metadata) do |vid|
        { title: "T-#{color}", description: color,
          seconds: 30, published_on: '2026-05-08' }
      end
      @mock = Rack::MockRequest.new(@middleware)
      res = post_json({ url: "https://www.youtube.com/watch?v=#{color.ljust(11, 'x')}" },
                      auth: 'secrettoken123')
      assert_equal 201, res.status
      expected_bucket = { 'yellow' => 'promoted',
                          'purple' => 'promoted_violet',
                          'red'    => 'promoted_red' }[color]
      assert_equal expected_bucket,
                   JSON.parse(res.body).dig('tag_added', 'bucket'),
                   "color #{color} should pick bucket #{expected_bucket}"
    end
  end

  def test_sniff_matches_first_whole_word_even_if_part_of_phrase
    # Heuristic is intentionally loose: any leading color word triggers
    # the tag, regardless of what follows. If stricter matching is
    # needed, send tag_color explicitly in the body.
    @middleware.define_singleton_method(:fetch_metadata) do |vid|
      { title: "T#{vid}", description: 'Red things from the desert',
        seconds: 30, published_on: '2026-05-08' }
    end
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk' },
                    auth: 'secrettoken123')
    assert_equal 201, res.status
    assert_equal 'promoted_red', JSON.parse(res.body).dig('tag_added', 'bucket')
  end

  def test_sniff_no_op_when_description_has_no_color_word
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk' },
                    auth: 'secrettoken123')
    assert_equal 201, res.status
    assert_nil JSON.parse(res.body)['tag_added']
    tags = read_tags
    assert_empty tags['promoted']
    assert_empty tags['promoted_violet']
    assert_empty tags['promoted_red']
  end

  def test_409_when_already_exists
    @db = FakeDbManager.new(existing: { 'abcdefghijk' => 1234 })
    inner = ->(_env) { [200, {}, []] }
    @middleware = DaVaz::Util::ApiVideos.new(
      inner, db_manager: @db, tokens_file: @tokens_file.path)
    @middleware.define_singleton_method(:fetch_metadata) do |_|
      { title: 't', description: '', seconds: 30, published_on: '2026-05-08' }
    end
    @mock = Rack::MockRequest.new(@middleware)
    res = post_json({ url: 'https://www.youtube.com/watch?v=abcdefghijk' },
                    auth: 'secrettoken123')
    assert_equal 409, res.status
    assert_equal 1234, JSON.parse(res.body)['id']
  end

  private

  def post_json(payload, auth:)
    headers = { 'CONTENT_TYPE' => 'application/json' }
    headers['HTTP_AUTHORIZATION'] = "Bearer #{auth}" if auth
    @mock.post('/api/videos', input: JSON.generate(payload), **headers)
  end
end
