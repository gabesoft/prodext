require 'spec_helper'

module Prodext
  module Vons
    describe Parser do
      before :each do
        @parser = Parser.new
      end

      it 'should return the correct url and step when calling parse with no arguments' do
        data = @parser.parse
        data[:step].should eq :init1
        data[:urls].length.should eq 1
      end

      it 'should return the correct url and step on init1' do
        data = @parser.parse '', { :step => :init1 }
        data[:step].should eq :init2
        data[:urls].length.should eq 1
      end

      it 'should return the correct url and step on init2' do
        data = @parser.parse '', { :step => :init2 }
        data[:step].should eq :category
        data[:urls].length.should eq 1
      end

      it 'should construct the correct category links' do
        html = File.read('spec/files/category.html')
        data = @parser.parse '', { :step => :init2 }
        data = @parser.parse html, data
        data.should be
        #data[:urls].length.should eq 4
        #data[:urls][0][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=9'
        #data[:urls][1][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=20'
        #data[:urls][2][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=24'
        #data[:urls][3][:url].should eq 'http://shop.safeway.com/Dnet/Aisles.aspx?ID=11'
        # TODO: we need to have data for each url individually
      end
    end
  end
end
