# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yummydata/version'

Gem::Specification.new do |spec|
  spec.name          = "yummydata"
  spec.version       = Yummydata::VERSION
  spec.authors       = ["Level Five Co., Ltd."]
  spec.email         = ["dev@level-five.jp"]

  spec.summary       = "Yummy Data Tools"
  spec.description   = "Yummy Data Tools"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "yard", "~> 0.8.7.6"

  spec.add_development_dependency "sparql", "~> 0"
  spec.add_development_dependency "sparql-client", "~> 0"
  
  spec.add_development_dependency "rdf-turtle", "~> 1.99"
  spec.add_development_dependency "rdf-rdfxml", "~> 1.99"
end
