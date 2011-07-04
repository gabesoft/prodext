require 'hpricot'

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

      def parse(html = nil, data = nil)
        if data.nil?
          url = 'http://shop.safeway.com/superstore/'
          { :urls => get_url_set(:get, url, { :step => :init1 }), :results => [] }
        else
          case data[:step]
          when :init1
            url = 'https://shop.safeway.com/register/registernew.asp?signin=1&returnTo=&register=&rzipcode=90028&zipcode=90028'
            { :urls => get_url_set(:post, url, { :step => :init2 }), :results => [] }
          when :init2
            url = 'http://shop.safeway.com/Dnet/Departments.aspx'
            { :urls => get_url_set(:get, url, { :step => :category }), :results => [] }
          when :category
          when :aisle
          when :product
          end
        end
      end

      private 

      def get_url_set(method, url, state)
        [ get_url(method, url, state) ]
      end

      def get_url(method, url, state)
        { :url => url, :method => method, :state => state, :options => {} }
      end
    end

  end
end
