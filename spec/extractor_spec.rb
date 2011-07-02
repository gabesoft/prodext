$:.unshift(File.dirname(__FILE__))
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
      data.should eq ['a', 'a1', 'a2', 'a11']
    end
  end

  class SpecParser
    def initialize
      register_url 'a'
      register_url 'a1'
      register_url 'a2'
      register_url 'a11'
    end

    def parse(html = nil, data = nil)
      if html.nil?
        { :urls => [to_url('a')], :step => [:s1], :results => [] }
      else
        step = data[:step][-1]
        case step
        when :s1
          data[:step] << :s2
          data[:urls] = ['a1', 'a2'].map{|u| to_url u}
        when :s2
          data[:step] << :s3
          data[:urls] = [to_url('a11')]
        when :s3
          data[:step] << :s4
          data[:urls] = []
        end
        data[:results] = [html]
        data
      end
    end

    private

    def to_url relative_url
      { :url => (SpecWeb.get_url relative_url), :method => :get, :options => {} }
    end

    def register_url path
      SpecWeb.register_get path, path
    end
  end

end
