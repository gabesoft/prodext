require 'fakeweb'

FakeWeb.allow_net_connect = true # allow unregistered connections
#FakeWeb.allow_net_connect = false

module Prodext
  SPEC_DOMAIN = 'http://www.myapp.com/'
  AUTH_DOMAIN = 'https://www.myapp.com/'

  FakeWeb.register_uri :get, SPEC_DOMAIN + 'page1', :body => 'page1'
  FakeWeb.register_uri :post, AUTH_DOMAIN + 'page2?a=b&c=d', :body => 'page2'
end
