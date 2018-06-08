# frozen_string_literal: true

require 'bundler/setup'
require 'weighted_sampler'

require 'pry'
require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.profile_examples = 2
  config.order = :random

  Kernel.srand config.seed

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
