
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'weighted_sampler/version'

Gem::Specification.new do |spec|
  spec.name          = 'weighted_sampler'
  spec.version       = WeightedSampler::VERSION
  spec.authors       = ['Oleksiy Babich']
  spec.email         = ['oleksiy@oleksiy.od.ua']

  spec.summary       = 'Weighted Sampler helps you to pick a random samples from a collection with defined probabilities or weights'
  spec.description   = %(
    Weighted Sampler helps you to pick a random samples from a collection with defined probabilities or weights.
    You can pass an Array or a Hash with desired probabilities
    and use Module or Class API to pick samples.

    Please, see documentation in the repo https://gitlab.com/oleksiy/weighted_sampler
  )
  spec.homepage      = 'https://gitlab.com/oleksiy/weighted_sampler'
  spec.license       = 'MIT'

  spec.files = %w(LICENSE.txt README.md) + Dir['lib/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
