$:.unshift(File.dirname(__FILE__))
require 'prodext/version'
require 'net/https'
require 'optparse'
require 'pp'

module Prodext

  #def self.run_old
    #http_method = ARGV.shift
    #url = ARGV.shift
    #cookies_path = ARGV.shift
    #content = get_usage

    #if !(url.nil? || url.empty?)
      #case http_method
      #when 'GET'
        #content = page_get url, cookies_path
      #when 'POST'
        #content = page_post url, cookies_path, {}
      #end
    #end

    #puts content
  #end

  def self.run
    options = parse_options

  end

  def self.parse_options
    options = {}
    parser = OptionParser.new do |opts|
      opts.on '-h', '--help', 'display this screen' do
        puts opts
        exit
      end

      opts.on '-r', '--request method,url,cookies', Array, 'make a web request given an http method, a url, and a cookies file path' do |l|
        #TODO: check l.length and add defaults as necessary
        options[:request] = true
        options[:method] = l[0]
        options[:url] = l[1]
        options[:cookies] = l[2]
      end

      opts.on '-e', '--extract parser,output', Array, 'extract products given a parser and an output file path' do |l|
        options[:extract] = true
        options[:parser] = l[0]
        options[:output] = l[1]
      end

    end
    parser.parse!

    pp "Options: ", options
    pp "ARGV: ", ARGV

    options
  end

  private

  def self.page_get(url, cookies_path = nil)
    uri = URI.parse url
    cookies = load_cookies cookies_path
    response = HTTP.get uri, cookies
    save_cookies response, cookies, cookies_path
    response.body
  end

  def self.page_post(url, cookies_path = nil, params)
    uri = URI.parse url
    cookies = load_cookies cookies_path
    response = HTTP.post uri, cookies, params
    save_cookies response, cookies, cookies_path
    response.body
  end

  def self.load_cookies cookies_path
    CookieStoreSerializer.file_load cookies_path
  end

  def self.save_cookies(response, cookies, cookies_path)
    cookies.merge! response['Set-Cookie']
    CookieStoreSerializer.file_save cookies_path, cookies
  end
end
