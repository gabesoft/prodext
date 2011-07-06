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
        doc = Hpricot html
        container = doc/'form[@name=Products]'
        products = (container/'script').select {|s| /^RenderProductRow/.match s.inner_html }
        pat = /^RenderProductRow\('(?<display_type>[^']*)'\s*,\s*
                                  '(?<gw_product_swgt>[^']*)'\s*,\s*
                                   (?<bpr_tpn>\d+)\s*,\s*
                                  '(?<cf_dsc>[^']*)'\s*,\s*
                                  '(?<product_type>[^']*)'\s*,\s*
                                   (?<ilabel>\d+)\s*,\s*
                                   (?<price>[0-9.+-]+)\s*,\s*
                                  '(?<display_price>[^']*)'\s*,\s*
                                  '(?<display_unit>[^']*)'\s*,\s*
                                  '(?<grey_price>[^']*)'\s*,\s*
                                  '(?<grey_unit>[^']*)'\s*,\s*
                                   (?<favorite_flag>true|false)\s*,\s*
                                  '(?<promo_desc>[^']*)'\s*,\s*
                                  '(?<promo_enddate>[^']*)'\s*,\s*
                                  '(?<inline_promo_code>[^']*)'\s*,\s*
                                  '(?<comments>[^']*)'\s*,\s*
                                   (?<avg_weight>[0-9.+-]+)\s*,\s*
                                   (?<min_weight>[0-9.+-]+)\s*,\s*
                                   (?<max_weight>[0-9.+-]+)\s*,\s*
                                   (?<inc>[0-9.+-]+)\s*,\s*
                                   (?<display_quantity>\d+)\s*,\s*
                                   (?<trigger_quantity>\d+)\s*,\s*
                                   (?<item_count>\w+)\s*,\s*
                                   (?<unavailable_message>true|false)\s*,\s*
                                  '(?<unit_of_measure>[^']*)'\s*,\s*
                                   (?<unit_price>[0-9.+-]+)\s*,\s*
                                   (?<weight_box_width>\d+)\s*,\s*
                                  '(?<help_text>[^']*)'\s*,\s*
                                   (?<div_id>\w+)\s*,\s*
                                  '(?<mode>[^']*)'\s*,\s*
                                   (?<orig_qty>\d+)\s*,\s*
                                  '(?<best_sub>[^']*)'\s*,\s*
                                  '(?<subs_cd>[^']*)'\s*,\s*
                                  '(?<substxt>[^']*)'\s*,\s*
                                  '(?<shelf_id>[^']*)'\s*,\s*
                                  '(?<product_detail>[^']*)'\s*,\s*
                                  '(?<shelf_name>[^']*)'\s*,\s*
                                  '(?<aisle_name>[^']*)'\s*,\s*
                                   (?<store_id>\w+)\s*,\s*
                                  '(?<search_term>[^']*)'\s*,\s*
                                  '(?<enable_pagination>[^']*)'\s*
                                  \)/ix
        products.map do |p|
          match = pat.match p.inner_html
          match.nil? ? nil : { 
            :category => state[:category],
            :display_type => match['display_type'],
            :gw_product_swgt => match['gw_product_swgt'],
            :bpr_tpn => match['bpr_tpn'],
            :cf_dsc => match['cf_dsc'],
            :product_type => match['product_type'],
            :ilabel => match['ilabel'],
            :price => match['price'],
            :display_price => match['display_price'],
            :display_unit => match['display_unit'],
            :grey_price => match['grey_price'],
            :grey_unit => match['grey_unit'],
            :favorite_flag => match['favorite_flag'],
            :promo_desc => match['promo_desc'],
            :promo_enddate => match['promo_enddate'],
            :inline_promo_code => match['inline_promo_code'],
            :comments => match['comments'],
            :avg_weight => match['avg_weight'],
            :min_weight => match['min_weight'],
            :max_weight => match['max_weight'],
            :inc => match['inc'],
            :display_quantity => match['display_quantity'],
            :trigger_quantity => match['trigger_quantity'],
            :item_count => match['item_count'],
            :unavailable_message => match['unavailable_message'],
            :unit_of_measure => match['unit_of_measure'],
            :unit_price => match['unit_price'],
            :weight_box_width => match['weight_box_width'],
            :help_text => match['help_text'],
            :div_id => match['div_id'],
            :mode => match['mode'],
            :orig_qty => match['orig_qty'],
            :best_sub => match['best_sub'],
            :subs_cd => match['subs_cd'],
            :substxt => match['substxt'],
            :shelf_id => match['shelf_id'],
            :product_detail => match['product_detail'],
            :shelf_name => match['shelf_name'],
            :aisle_name => match['aisle_name'],
            :store_id => match['store_id'],
            :search_term => match['search_term'],
            :enable_pagination => match['enable_pagination']
          }
        end.compact
      end

      def parse_product_urls(html, state)
        doc = Hpricot html
        container = doc/'div.shopByAisleContainer'
        links = container/'a.leftnav_dept'
        pat = /UpdateFrames\('SHELF',
                             '(?<did>)[^']*',
                             '(?<aid>[^']*)',
                             '(?<shelf_id>[0-9_]+)',
                             "(?<dept_name>[^"]+)",
                             "(?<aisle_name>[^"]+)",
                             "(?<shelf_name>[^"]+)"\)/x
        links.map do |a|
          link_state = { :step => :product, :category => "#{state[:category]}:#{a.inner_html}" }
          text = CGI.unescapeHTML a.attributes['onclick']
          match = pat.match text

          url = get_url 'superstore/shelf.asp', {
            :shelfid    => match['shelf_id'],
            :deptname   => match['dept_name'],
            :aislename  => match['aisle_name'],
            :shelfname  => match['shelf_name']
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

        query = query_hash.map do |key, value|
          param = URI.escape value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
          "#{key}=#{param}"
        end.join '&'

        base + (query.empty? ? '' : '?') + query
      end
    end

  end
end
