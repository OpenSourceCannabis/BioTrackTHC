# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'BioTrackTHC/version'

Gem::Specification.new do |spec|
  spec.name          = 'BioTrackTHC'
  spec.version       = BioTrackTHC::VERSION
  spec.authors       = ['Emanuele Tozzato']
  spec.email         = ['etozzato@gmail.com']

  spec.summary       = %q{Pull and push lab data between a LIMS and BioTrackTHC}
  spec.description   = %q{A simple gem to pull lab tests and push results to BioTrackTHC }
  spec.homepage      = 'https://420tech.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'mechanize'
  spec.add_dependency 'bundler', '>= 1.7.3'
  spec.add_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
end
