require 'hpricot'
require 'cgi'

module Prodext
  module Vons

    class Parser

      #- :init1 prodext GET http://shop.safeway.com/superstore/ tmp/safeway.txt
      #- :init2 prodext POST "https://shop.safeway.com/register/registernew.asp?signin=1&returnTo=&register=&rzipcode=90028&zipcode=90028" "tmp/safeway.txt" 
      #- :category prodext GET "http://shop.safeway.com/Dnet/Departments.aspx" "tmp/safeway.txt" 
      #- :aisle
      #- :shelf
      #- :product

      def initialize

      end

      def parse(html = nil, state = nil)
        if state.nil?
          url = 'http://shop.safeway.com/superstore/'
          { :urls => get_url_set(:get, url, { :step => :init1 }), :results => [] }
        else
          case state[:step]
          when :init1
            url = 'https://shop.safeway.com/register/registernew.asp?signin=1&returnTo=&register=&rzipcode=90028&zipcode=90028'
            { :urls => get_url_set(:post, url, { :step => :init2 }), :results => [] }
          when :init2
            url = 'http://shop.safeway.com/Dnet/Departments.aspx'
            { :urls => get_url_set(:get, url, { :step => :category }), :results => [] }
          when :category
            { :urls => parse_aisle_urls(html, state), :results => [] }
          when :aisle
            { :urls => parse_shelf_urls(html, state), :results => [] }
          when :shelf
            { :urls => parse_product_urls(html, state), :results => [] }
          when :product
            { :urls => [], :results => parse_products(html, state) }
          end
        end
      end

      private 

      def parse_products(html, state)
        []
      end

      #TODO: refactor url creation
      #      base = http://shop.safeway.com/
      #
      def parse_product_urls(html, state)
        doc = Hpricot html
        container = doc/'div.shopByAisleContainer'
        links = container/'a.leftnav_dept'
        pat = /UpdateFrames\('SHELF',
                             '(?<did>)[^']*',
                             '(?<aid>[^']*)',
                             '(?<shelfid>[0-9_]+)',
                             "(?<deptname>[^"]+)",
                             "(?<aislename>[^"]+)",
                             "(?<shelfname>[^"]+)"\)/x
        links.map do |a|
          link_state = { :step => :product, :category => "#{state[:category]}:#{a.inner_html}" }
          text = CGI.unescapeHTML a.attributes['onclick']
          match = pat.match text

          shelfid   = URI.escape match['shelfid'], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
          deptname  = URI.escape match['deptname'], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
          aislename = URI.escape match['aislename'], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
          shelfname = URI.escape match['shelfname'], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")

          url = "http://shop.safeway.com/superstore/shelf.asp?shelfid=#{shelfid}&deptname=#{deptname}&aislename=#{aislename}&shelfname=#{shelfname}"
          get_url :get, url.strip, link_state
        end
      end

      def parse_shelf_urls(html, state)
        doc = Hpricot html
        container = doc/'div.shopByAisleContainer'
        links = container/'a.leftnav_dept'
        pat = /UpdateFrames\(('|")(\d+_\d+)('|")\)/x
        links.map do |a|
          link_state = { :step => :shelf, :category => "#{state[:category]}:#{a.inner_html}" }
          id = pat.match(a.attributes['onclick'])[2]
          url = "http://shop.safeway.com/Dnet/Shelves.aspx?ID=#{id}"
          get_url :get, url, link_state
        end
      end

      def parse_aisle_urls(html, state)
        doc = Hpricot html
        container = doc/'div.shopByAisleContainer'
        links = container/'a.leftnav_dept'
        pat = /UpdateFrames\(('|")(\d+)('|")\)/x
        links.map do |a|
          link_state = { :step => :aisle, :category => a.inner_html }
          id = pat.match(a.attributes['onclick'])[2]
          url = "http://shop.safeway.com/Dnet/Aisles.aspx?ID=#{id}"
          get_url :get, url, link_state
        end
      end

      def get_url_set(method, url, state)
        [ get_url(method, url, state) ]
      end

      def get_url(method, url, state)
        { :url => url, :method => method, :state => state, :options => {} }
      end
    end

  end
end
