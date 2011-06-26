require 'spec_helper'

describe Prodext do
  describe "fetch_page" do
    before :each do
      #TODO: add before ops here
    end

    it "should return the html of a given page url" do
      html = Prodext.fetch_page "http://www.google.com"
      html.should include "html"
    end
  end
end
