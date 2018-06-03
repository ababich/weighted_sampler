
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'weighted_sampler/version'

Gem::Specification.new do |spec|
  spec.name          = 'weighted_sampler'
  spec.version       = WeightedSampler::VERSION
  spec.authors       = ['Oleksiy Babich']
  spec.email         = ['oleksiy@oleksiy.od.ua']

  spec.summary       = 'Picks random sample tacking in account probabilities or weights for each element'
  spec.description   = %(
    This gem provides functionality to pick samples from an array taking in account element weights

    Weights will be normalized automatically
  )
  spec.homepage      = 'https://gitlab.com/alexey_b/weighted_sampler'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
