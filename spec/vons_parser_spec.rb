require 'spec_helper'

module Prodext
  module Vons
    describe Parser do
      before :each do
        @parser = Parser.new
      end

      it 'should return the correct url and step when calling parse with no arguments' do
        data = @parser.parse
        urls = data[:urls]
        urls.length.should eq 1
        urls[0][:state][:step].should eq :init1
      end

      it 'should return the correct url and step on init1' do
        data = @parser.parse '', { :step => :init1 }
        urls = data[:urls]
        urls.length.should eq 1
        urls[0][:state][:step].should eq :init2
      end

      it 'should return the correct url and step on init2' do
        data = @parser.parse '', { :step => :init2 }
        urls = data[:urls]
        urls.length.should eq 1
        urls[0][:state][:step].should eq :category
      end

      it 'should construct the correct category links' do
        html = File.read('spec/files/category.html')
        data = @parser.parse '', { :step => :init2 }
        data = @parser.parse html, data
        data.should be
        urls = data[:urls]
        urls.length.should eq 4
        urls[0][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=9'
        urls[1][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=20'
        urls[2][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=24'
        urls[3][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=11'

        urls[0][:state][:category].should eq 'Canned Goods & Soups'
        urls[1][:state][:category].should eq 'Condiments/Spices & Bake'
        urls[2][:state][:category].should eq 'Cookies, Snacks & Candy'
        urls[3][:state][:category].should eq 'Dairy, Eggs & Cheese'
      end
    end
  end
end
