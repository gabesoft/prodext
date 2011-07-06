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
          url = get_url 'superstore/'
          { :urls => [ get_url_data(:get, url, { :step => :init1 }) ], :results => [] }
        else
          case state[:step]
          when :init1
            url = get_url 'register/registernew.asp', {
              :signin => '1', :returnto => '', :register => '', :rzipcode => '90024', :zipcode => '90024'
            }, true
            { :urls => [ get_url_data(:post, url, { :step => :init2 }) ], :results => [] }
          when :init2
            url = get_url 'dnet/departments.aspx'
            { :urls => [ get_url_data(:get, url, { :step => :category }) ], :results => [] }
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

          url = get_url 'superstore/shelf.asp', { 
            :shelfid    => match['shelfid'],
            :deptname   => match['deptname'],
            :aislename  => match['aislename'],
            :shelfname  => match['shelfname']
          }
          get_url_data :get, url.strip, link_state
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
          url = get_url 'dnet/shelves.aspx', { :id => id }
          get_url_data :get, url, link_state
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
          url = get_url 'dnet/aisles.aspx', { :id => id }
          get_url_data :get, url, link_state
        end
      end

      def get_url_data(method, url, state)
        { :url => url, :method => method, :state => state, :options => {} }
      end

      def get_url(relative_path, query_hash={}, secure=false)
        protocol = secure ? 'https' : 'http'
        base = "#{protocol}://shop.safeway.com/#{relative_path}"

        query = query_hash.collect do |key, value|
          param = URI.escape value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
          "#{key}=#{param}"
        end.join '&'

        base + (query.empty? ? '' : '?') + query
      end
    end

  end
end
