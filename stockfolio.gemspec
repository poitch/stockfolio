require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/stockfolio/version"

Gem::Specification.new do |spec|
    spec.name = "StockFolio"
    spec.version = StockFolio::VERSION
    spec.authors = ["Jerome Poichet"]
    spec.email = "poitch@gmail.com"
    spec.homepage = "http://github.com/poitch/stockfolio"
    spec.summary = "Track stock portfolio from the command line"
    spec.executables = %w(stockfolio)
    spec.add_dependency 'boson'
    spec.add_dependency 'hirb'
    spec.files = Dir.glob(%w[{lib}/**/*.rb bin/*])
    spec.require_paths << "lib"
end

