require 'net/https'

module Prodext
  class Extractor
    def initialize
      @cookies = CookieStore.new
    end

    def extract parser
      data = parser.parse
      @urls = data[:urls]
      @results = []

      while @urls.length > 0 do
        url_data = @urls.shift
        html = make_request url_data
        data = parser.parse html, url_data[:state]
        @urls.concat data[:urls]
        @results.concat data[:results]
      end

      @results
    end

    private

    def make_request url_data
      url = url_data[:url]
      method = url_data[:method]
      params = url_data[:params]

      case method
      when :get
        page_get url
      when :post
        page_post url, params
      else
        "invalid http method: #{method}"
      end
    end

    def page_get url
      uri = URI.parse url
      response = HTTP.get uri, @cookies
      @cookies.merge! response['Set-Cookie']
      response.body
    end

    def page_post(url, params)
      uri = URI.parse url
      response = HTTP.post uri, @cookies, params
      @cookies.merge! response['Set-Cookie']
      response.body
    end
  end
end
