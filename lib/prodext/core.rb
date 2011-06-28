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

  def self.page_get(url, cookies_path = nil)
    uri = URI.parse url
    cookies = CookieStoreSerializer.file_load cookies_path
    response = http_get uri, cookies

    cookies.merge! response['Set-Cookie']
    CookieStoreSerializer.file_save cookies_path, cookies

    response.body
  end

  def self.page_post(url, cookies_path = nil, params)
    uri = URI.parse url
    cookies = CookieStoreSerializer.file_load cookies_path
    response = http_post uri, cookies, params
    
    cookies.merge! response['Set-Cookie']
    CookieStoreSerializer.file_save cookies_path, cookies

    response.body
  end

  def self.http_get(uri, cookies)
    http = Net::HTTP.new uri.host, uri.port
    opts = {}
    opts['Cookie'] = cookies.to_s unless cookies.empty?

    request = Net::HTTP::Get.new uri.request_uri, opts
    response = http.start.request request
    response
  end

  def self.http_post(uri, cookies, params)
    http = Net::HTTP.new uri.host, uri.port
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    opts = {}
    opts['Cookie'] = cookies.to_s unless cookies.empty?

    request = Net::HTTP::Post.new uri.request_uri, opts
    request.set_form_data params

    response = http.request request
    response
  end

  def self.show_usage
    puts <<-INFO
Usage:
  prodext <url> <cookies-path>
    INFO
  end

end
