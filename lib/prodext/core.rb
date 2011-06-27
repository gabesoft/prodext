require 'prodext/version'
require 'net/https'

module Prodext
  #class CookieStore
  #end

  def self.run
    url = ARGV.shift
    if url.nil? || url.empty?
      show_usage
    else
      html = fetch_page url
      puts html
    end
  end

  def self.fetch_page url
    uri = URI.parse url
    response = get_response uri
    response.body
  end

  def self.get_response uri
    http = Net::HTTP.new uri.host, uri.port
    request = Net::HTTP::Get.new uri.request_uri
    response = http.start.request request
    p response['Set-Cookie']
    response
  end
  
  def self.show_usage
      puts <<-INFO
Usage:
  prodext <url>
      INFO
  end
end
