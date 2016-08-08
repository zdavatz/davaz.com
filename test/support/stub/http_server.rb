require 'webrick'
require 'sbsm/request'
require 'util/trans_handler'

class Object
  def meta_class; class << self; self; end; end
  def meta_eval &blk; meta_class.instance_eval &blk; end
end


module WEBrick
  class HTTPServer
    attr_accessor :document_root
  end

  class HTTPRequest
    attr_accessor :server, :uri, :notes

    alias :__old_initialize__ :initialize

    def initialize(*args)
      __old_initialize__(*args)
      @notes = DaVaz::Stub::Notes.new
    end

    def headers_in
      headers = {}
      if @header
        @header.each { |key, vals| headers.store(key, vals.join(';')) }
      end
      headers
    end

    def uri
      @uri || unparsed_uri
    end
  end

  class HTTPResponse
    attr_accessor :rawdata

    alias :__old_send_header__ :send_header

    def send_header(socket)
      if @rawdata
        _write_data(socket, status_line)
      else
        __old_send_header__(socket)
      end
    end

    alias :__old_setup_header__ :setup_header

    def setup_header()
      unless @rawdata
        __old_setup_header__
      end
    end
  end
end

module SBSM
  class Request

    def handle_exception(e)
      raise e
    end
  end

  module Apache
    DECLINED = nil

    def Apache.request=(request)
      @request = request
    end

    def Apache.request
      @request
    end
  end
end

class CGI
  attr_accessor :output

  def stdoutput
    output
  end

  public :env_table
end

module DaVaz
  module Stub

    class Notes < Hash
      alias :add :store
    end

    class Output < String
      alias :write :<<
      alias :print :<<
    end

    def self.http_server(drburi)
      doc = File.expand_path('../../../doc', File.dirname(__FILE__))
      server_args = {
        :Port         => TEST_SRV_URI.port,
        :BindAddress  => TEST_SRV_URI.host,
        :DocumentRoot => doc,
        :Logger       => WEBrick::Log.new('/dev/null'),
        :AccessLog    => []
      }
      if DEBUG
        server_args[:Logger]    = WEBrick::Log.new($stdout)
        server_args[:AccessLog] = nil
      end
      server = WEBrick::HTTPServer.new(server_args)
      # for SBSM::TransHandler
      server.document_root = doc

      davaz = Proc.new do |req, resp|
        resp.chunked = true
        if req.uri == '/favicon.ico'
          resp.chunked = true
          resp.body = File.open(File.join(doc, req.uri))
        else
          req.server = server
          Util::TransHandler.instance.translate_uri(req)
          # Not Threadsafe!
          SBSM::Apache.request = req
          output = Output.new
          sbsm = SBSM::Request.new(drburi)
          sbsm.meta_eval { define_method(:handle_exception) { |e| raise e } }
          sbsm.cgi.params.update(req.query)
          sbsm.cgi.env_table['SERVER_NAME'] = \
            "#{TEST_SRV_URI.host}:#{TEST_SRV_URI.port}"
          sbsm.cgi.env_table['REQUEST_METHOD'] = req.request_method
          sbsm.cgi.cookies['_session_id'] = 'test:preset-session-id'
          sbsm.cgi.output = output
          sbsm.process
          if /^location:/i.match(output)
            resp.status = 303
          end
          resp.rawdata = true
          resp.body = output
        end
      end

      server.mount_proc('/', &davaz)
      server.mount_proc('/en', &davaz)
      server.mount_proc('/en/.*', &davaz)
      res = File.join(doc, 'resources')
      server.mount('/resources',
        WEBrick::HTTPServlet::FileHandler, res, {})
      ups = File.join(res, 'uploads')
      server.mount('/resources/uploads',
        WEBrick::HTTPServlet::FileHandler, ups, {})

      server
    end
  end
end
