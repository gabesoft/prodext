require 'prodext/version'
require 'net/https'

module Prodext

  def self.run
    url = ARGV.shift
    cookies_path = ARGV.shift

    if url.nil? || url.empty?
      show_usage
    else
      html = fetch_page url, cookies_path
      puts html
    end
  end

  def self.fetch_page(url, cookies_path = nil)
    uri = URI.parse url
    cookies = CookieStoreSerializer.file_load cookies_path
    response = get_response uri, cookies
    body = response.body
    cookies.merge! response['Set-Cookie']
    CookieStoreSerializer.file_save cookies_path, cookies
    body
  end

  def self.get_response(uri, cookies)
    http = Net::HTTP.new uri.host, uri.port
    opts = {}
    opts['Cookie'] = cookies.to_s unless cookies.empty?

    request = Net::HTTP::Get.new uri.request_uri, opts
    response = http.start.request request
    response
  end

  def self.show_usage
    puts <<-INFO
Usage:
  prodext <url> <cookies-path>
    INFO
  end

end
