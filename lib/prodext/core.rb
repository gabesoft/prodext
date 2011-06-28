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

  private 

  def self.http_get(uri, cookies)
    http = get_http uri

    opts = {}
    opts['Cookie'] = cookies.to_s unless cookies.empty?

    request = Net::HTTP::Get.new uri.request_uri, opts

    http.start.request request
  end

  def self.http_post(uri, cookies, params)
    http = get_http uri

    opts = {}
    opts['Cookie'] = cookies.to_s unless cookies.empty?

    request = Net::HTTP::Post.new uri.request_uri, opts
    request.set_form_data params

    http.request request
  end

  def self.get_http uri
    http = Net::HTTP.new uri.host, uri.port
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http
  end

  def self.get_usage
    <<-INFO
Usage:
  prodext <http-method (GET,POST)> <url> <cookies-path>
    INFO
  end

end
