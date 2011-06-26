require 'prodext/version'
require 'net/https'


module Prodext
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
    req = Net::HTTP::Get.new uri.path.empty? ? '/' : uri.path
    res = http.start.request req
    res
  end

  def self.show_usage
      puts <<-INFO
Usage:
  prodex <url>
      INFO
  end
end
