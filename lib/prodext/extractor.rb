require 'net/https'

module Prodext
  class Extractor
    def initialize(opts = nil)
      @urls = []
      @results = []
      @cookies_path = opts[:cookies] unless opts.nil?
    end

    def extract parser
      data = parser.parse
      @urls.concat data[:urls]
      while @urls.length > 0 do
        url_data = @urls.shift
        html = make_request url_data
        data = parser.parse html, url_data[:state]
        @urls.concat data[:urls]
        @results.concat data[:results]
      end
      @results
    end

    def make_request url_data
      url = url_data[:url]
      method = url_data[:method]
      params = url_data[:params]

      case method
      when :get
        page_get url, @cookies_path
      when :post
        page_post url, @cookies_path, params 
      else
        "invalid http method: #{method}"
      end
    end

    def page_get(url, cookies_path = nil)
      uri = URI.parse url
      cookies = CookieStoreSerializer.file_load cookies_path
      response = HTTP.get uri, cookies

      cookies.merge! response['Set-Cookie']
      CookieStoreSerializer.file_save cookies_path, cookies

      response.body
    end

    def self.page_post(url, cookies_path = nil, params)
      uri = URI.parse url
      cookies = CookieStoreSerializer.file_load cookies_path
      response = HTTP.post uri, cookies, params

      cookies.merge! response['Set-Cookie']
      CookieStoreSerializer.file_save cookies_path, cookies

      response.body
    end
  end
end
