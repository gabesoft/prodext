# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "prodext/version"

Gem::Specification.new do |s|
  s.name          = "prodext"
  s.authors       = %w{gabriel}
  s.email         = %w{gabesoft@gmail.com}

  s.platform      = Gem::Platform::RUBY
  s.version       = Prodext::VERSION

  s.homepage      = "http://github.com/gabesoft/prodext"
  s.summary       = "Product extractor"
  s.description   = ""

  s.rubyforge_project = "prodext"

  s.require_paths = %w{lib}
  s.executables   = %w{prodext}
  s.files         = %w{README Rakefile} + Dir['lib/**/*.rb']
  s.test_files    = Dir['spec/*.rb']
end
