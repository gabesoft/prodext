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
        urls[0][:url].should eq 'http://shop.safeway.com/superstore/'
      end

      it 'should return the correct url and step on init1' do
        data = @parser.parse '', { :step => :init1 }
        urls = data[:urls]
        urls.length.should eq 1
        urls[0][:state][:step].should eq :init2
        urls[0][:url].should eq 'https://shop.safeway.com/register/registernew.asp?signin=1&returnto=&register=&rzipcode=90024&zipcode=90024'
      end

      it 'should return the correct url and step on init2' do
        data = @parser.parse '', { :step => :init2 }
        urls = data[:urls]
        urls.length.should eq 1
        urls[0][:state][:step].should eq :category
        urls[0][:url].should eq 'http://shop.safeway.com/dnet/departments.aspx'
      end

      it 'should construct the correct aisle links' do
        html = File.read 'spec/files/category.html'
        data = @parser.parse html, { :step => :category }
        urls = data[:urls]

        urls.length.should eq 4

        urls[0][:url].should eq 'http://shop.safeway.com/dnet/aisles.aspx?id=9'
        urls[1][:url].should eq 'http://shop.safeway.com/dnet/aisles.aspx?id=20'
        urls[2][:url].should eq 'http://shop.safeway.com/dnet/aisles.aspx?id=24'
        urls[3][:url].should eq 'http://shop.safeway.com/dnet/aisles.aspx?id=11'

        urls[0][:state][:step].should eq :aisle
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
        urls[0][:url].should eq 'http://shop.safeway.com/dnet/shelves.aspx?id=5_1'
        urls[1][:url].should eq 'http://shop.safeway.com/dnet/shelves.aspx?id=5_2'
        urls[2][:url].should eq 'http://shop.safeway.com/dnet/shelves.aspx?id=5_3'

        urls[0][:state][:step].should eq :shelf
        urls[0][:state][:category].should eq 'stuff:Coffee'
        urls[1][:state][:category].should eq 'stuff:Hot Tea, Cider & Cocoa'
        urls[2][:state][:category].should eq 'stuff:Juice & Nectars'
      end

      it 'should construct the correct product links' do
        html = File.read 'spec/files/shelf.html'
        data = @parser.parse html, { :step => :shelf, :category => 'catA:aisleB' }
        urls = data[:urls]

        urls.length.should eq 3
        urls[0][:url].should eq 'http://shop.safeway.com/superstore/shelf.asp?shelfid=5_3_1&deptname=Beverages&aislename=Juice%20%26%20Nectars&shelfname=Juice%20-%20Apple%20%26%20Cider'
        urls[1][:url].should eq 'http://shop.safeway.com/superstore/shelf.asp?shelfid=5_3_2&deptname=Beverages&aislename=Juice%20%26%20Nectars&shelfname=Juice%20-%20Berry%20%26%20Blends'
        urls[2][:url].should eq 'http://shop.safeway.com/superstore/shelf.asp?shelfid=5_3_3&deptname=Beverages&aislename=Juice%20%26%20Nectars&shelfname=Juice%20-%20Cranberry'

        urls[0][:state][:step].should eq :product
        urls[0][:state][:category].should eq 'catA:aisleB:Juice - Apple & Cider'
        urls[1][:state][:category].should eq 'catA:aisleB:Juice - Berry & Blends'
        urls[2][:state][:category].should eq 'catA:aisleB:Juice - Cranberry'
      end

      it 'should parse the products from html' do
        html = File.read 'spec/files/product.html'
        data = @parser.parse html, { :step => :product, :category => 'juice' }
        results = data[:results]

        results.length.should eq 3
        results[0][:category].should eq 'juice'

        results[0][:cf_dsc].should eq 'Hansens Apple Raspberry - 64 Fl. Oz.'
        results[1][:cf_dsc].should eq 'Hansens Natural Apple Juice - 64 Fl. Oz.'
        results[2][:cf_dsc].should eq 'Martinelli Apple Juice - 128 Fl. Oz.'

        results[0][:price].should eq '4.09'
        results[1][:price].should eq '3.79'
        results[2][:price].should eq '10.99'
      end
    end
  end
end
