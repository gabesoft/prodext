# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "prodext/version"

Gem::Specification.new do |s|
  s.name        = "prodext"
  s.version     = Prodext::VERSION
  s.authors     = ["gabriel"]
  s.email       = ["gabesoft@gmail.com"]
  s.homepage    = "http://github.com/gabesoft/prodext"
  s.summary     = "Product extractor"
  s.description = ""

  s.rubyforge_project = "prodext"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
