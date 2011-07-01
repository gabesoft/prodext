require 'prodext/version'
require 'net/https'

module Prodext

  def self.run
    http_method = ARGV.shift
    url = ARGV.shift
    cookies_path = ARGV.shift
    content = get_usage

    if !(url.nil? || url.empty?)
      case http_method
      when 'GET'
        content = page_get url, cookies_path
      when 'POST'
        content = page_post url, cookies_path, {}
      end
    end

    puts content
  end

  def self.page_get(url, cookies_path = nil)
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

  def self.get_usage
    <<-INFO
Usage:
  prodext <http-method (GET,POST)> <url> <cookies-path>
    INFO
  end

end
