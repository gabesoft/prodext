$:.unshift(File.dirname(__FILE__))
require 'prodext/version'
require 'net/https'
require 'optparse'
require 'pp'

module Prodext
  def self.run
    options = parse_options

    if options[:request]
      make_request options[:method], options[:url], options[:cookies]
    elsif options[:extract]
      extract_products options[:parser], options[:output]
    end
  end

  def self.extract_products(parser, output)

    case parser
    when 'vons'
      #TODO: extract products and save to output file as json
    else
      puts "unknown parser: #{parser}"
    end
  end

  def self.make_request(method, url, cookies)
    content = ''
    case method
    when 'GET'
      content = page_get url, cookies
    when 'POST'
      content = page_post url, cookies, {}
    end
    puts content
  end

  def self.parse_options
    options = {}
    parser = OptionParser.new do |opts|
      opts.on '-r', '--request method,url,cookies', Array, 'make a web request given an http method, a url, and a cookies file path' do |l|
        options[:request] = true
        options[:method] = l[0]   unless l.length < 1
        options[:url] = l[1]      unless l.length < 2
        options[:cookies] = l[2]  unless l.length < 3
      end

      opts.on '-e', '--extract parser,output', Array, 'extract products given a parser and an output file path' do |l|
        options[:extract] = true
        options[:parser] = l[0]   unless l.length < 1
        options[:output] = l[1]   unless l.length < 2
      end

      opts.on_tail '-h', '--help', 'display this screen' do
        puts opts
        exit
      end

      opts.on_tail '-v', '--version', 'show version' do
        puts 'prodext ' + Prodext::VERSION
        exit
      end
    end

    begin
      parser.parse!

      puts 'options detected'
      puts '----------------'
      pp options
      puts '----------------'

      options
    rescue OptionParser::InvalidOption
      puts parser
      exit
    end
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
