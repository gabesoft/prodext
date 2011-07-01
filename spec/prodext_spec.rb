require 'spec_helper'

describe Prodext do
  describe "page_get" do
    it "should return the html of a given page url" do
      html = Prodext.page_get "http://www.google.com"
      html.should include "html"
    end
  end

  describe "page_post" do
    it "should generate a post request to a given url" do

      url = "https://shop.safeway.com/register/registernew.asp?signin=1&returnTo=&register=&rzipcode=90028&zipcode=90028"
      html = Prodext.page_post url, nil, {}

      response = "<script language=\"javascript\">top.location = 'http://shop.safeway.com/superstore';</script>"
      html.should eq response
    end
  end
end
