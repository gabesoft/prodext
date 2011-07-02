require 'net/https'

module Prodext
  class Extractor
    def initialize(opts = nil)
      @urls = []
      @results = []
      @cookies_path = opts[:cookies] unless opts.nil?
    end

    def extract parser
      @urls = append_urls parser.parse
      while @urls.length > 0 do
        item = @urls.shift
        url = item[:url]
        data = item[:data]
        html = page_get url, @cookies_path
        data = parser.parse html, data
        append_urls data
        @results.concat data[:results]
      end
      @results
      #@results.flatten
    end

    def append_urls data
      urls = data[:urls]
      @urls.concat urls.map{|u| {:url => u, :data => data}}
    end

    def page_get(url, cookies_path = nil)
      uri = URI.parse url
      cookies = CookieStoreSerializer.file_load cookies_path
      response = HTTP.get uri, cookies

      cookies.merge! response['Set-Cookie']
      CookieStoreSerializer.file_save cookies_path, cookies

      response.body
    end
  end
end
