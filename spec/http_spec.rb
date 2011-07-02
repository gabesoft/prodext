require 'spec_helper'
require 'net/https'

module Prodext
  describe HTTP do
    before :each do
      SpecWeb.register_clear
    end

    describe "get" do
      it "should make a get request and return the page body" do
        SpecWeb.register_get 'page1', 'page1'
        html = HTTP.get (URI.parse "http://www.myapp.com/page1"), CookieStore.new
        html.body.should include "page1"
      end
    end

    describe "post" do
      it "should make a post request and return the page body" do
        SpecWeb.register_post 'page2?a=b&c=d', 'page2', true

        url = "https://www.myapp.com/page2?a=b&c=d"
        uri = URI.parse url
        html = HTTP.post uri, CookieStore.new, {}

        response = "page2"
        html.body.should eq response
      end
    end

  end
end
