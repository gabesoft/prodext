require 'spec_helper'
require 'net/https'

module Prodext
  describe HTTP do

    describe "page_get" do
      it "should make a get request and return the page body" do
        html = HTTP.get (URI.parse "http://www.myapp.com/page1"), CookieStore.new
        html.body.should include "page1"
      end
    end

    describe "page_post" do
      it "should make a post request and return the page body" do

        url = "https://www.myapp.com/page2?a=b&c=d"
        uri = URI.parse url
        html = HTTP.post uri, CookieStore.new, {}

        response = "page2"
        html.body.should eq response
      end
    end

  end
end
