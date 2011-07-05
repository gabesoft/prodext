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

      it 'should construct the correct aisle links' do
        html = File.read 'spec/files/category.html'
        #data = @parser.parse '', { :step => :init2 }
        #state = data[:urls][0][:state]
        #data = @parser.parse html, state
        data = @parser.parse html, { :step => :category }
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

      it 'should construct the correct shelf links' do
        html = File.read 'spec/files/aisle.html'
        data = @parser.parse html, { :step => :aisle, :category => 'stuff' }
        urls = data[:urls]

        urls.length.should eq 3
        urls[0][:url].should eq 'http://shop.safeway.com/Dnet/Shelves.aspx?ID=5_1'
        urls[1][:url].should eq 'http://shop.safeway.com/Dnet/Shelves.aspx?ID=5_2'
        urls[2][:url].should eq 'http://shop.safeway.com/Dnet/Shelves.aspx?ID=5_3'

        urls[0][:state][:category].should eq 'stuff:Coffee'
        urls[1][:state][:category].should eq 'stuff:Hot Tea, Cider & Cocoa'
        urls[2][:state][:category].should eq 'stuff:Juice & Nectars'
      end
    end
  end
end
