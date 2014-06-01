# -*- encoding: utf-8 -*-
require File.expand_path('../lib/shoes/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "shoes"
  s.version     = Shoes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Team Shoes"]
  s.email       = ["shoes@librelist.com"]
  s.homepage    = "https://github.com/shoes/shoes4"
  s.summary     = %q{Shoes is the best little GUI toolkit for Ruby. Shoes runs on JRuby only for now.}
  s.description = %q{Shoes is the best little GUI toolkit for Ruby. Shoes makes building for Mac, Windows, and Linux super simple. Shoes runs on JRuby only for now.}
  s.license     = 'MIT'

  s.files         = `git ls-files -- lib/shoes/ui`.split("\n").concat(['lib/shoes/version.rb'])
  s.test_files    = []
  s.require_paths = ["lib"]

  s.add_dependency "shoes-dsl", Shoes::VERSION
  s.add_dependency "shoes-swt", Shoes::VERSION

  s.add_dependency "furoshiki", ">=0.1.2" # For packaging
  s.add_dependency "nokogiri" # For converting the manual to HTML
end
