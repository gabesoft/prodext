require 'hpricot'

module Prodext
  class VonsParser

    #- prodext GET http://shop.safeway.com/superstore/ tmp/safeway.txt
    #- prodext POST "https://shop.safeway.com/register/registernew.asp?signin=1&returnTo=&register=&rzipcode=90028&zipcode=90028" "tmp/safeway.txt" 
    #- prodext GET "http://shop.safeway.com/Dnet/Departments.aspx" "tmp/safeway.txt" 

    def initialize

    end

    def parse(html = nil, data = nil)

    end
  end
end
