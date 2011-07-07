require 'spec_helper'

module Prodext
  describe Extractor do
    before :each do
      SpecWeb.register_clear
    end

    it 'should extract data according to the given parser' do
      parser = SpecParser.new
      extractor = Extractor.new
      data = extractor.extract parser
      data.should be
      data.should eq [ 'a', 'a1', 'a2', 'a11', 'a21' ]
    end
  end

  class SpecParser
    def initialize
      SpecWeb.register_get 'a', 'a'
      SpecWeb.register_get 'a1', 'a1'
      SpecWeb.register_get 'a2', 'a2'
      SpecWeb.register_post 'a11', 'a11'
      SpecWeb.register_post 'a21', 'a21'
    end

    def parse(html = nil, data = nil)
      if html.nil?
        { :urls => [ to_url('a', :get, { :step => :s1 }) ], :results => [] }
      else
        step = data[:step]
        urls = []

        case step
        when :s1
          urls = [ 'a1', 'a2' ].map{|u| to_url(u, :get, { :step => :s2 })}
        when :s2
          urls = [ to_url(html + '1', :post, { :step => :s3 }) ]
        end

        { :urls => urls, :results => [ html ] }
      end
    end

    private

    def to_url(relative_url, method, state)
      { :url => (SpecWeb.get_url relative_url), :method => method, :state => state, :options => {} }
    end
  end

end
