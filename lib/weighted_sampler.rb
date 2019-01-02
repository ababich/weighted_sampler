# frozen_string_literal: true

require 'weighted_sampler/version'
require 'pry'

module WeightedSampler

  # sum of floats are never stable enough to guarantee exact equality to 1
  ERROR_ALLOWANCE = 10**-8

  class Base

    def initialize(enum, seed: nil, skip_normalization: false)
      @random = Random.new(seed) unless seed.nil?

      if enum.is_a?(Hash)
        @p_margins = normalized_margins(enum.values, skip_normalization)
        @keys = enum.keys
      elsif enum.is_a?(Array)
        @p_margins = normalized_margins(enum, skip_normalization)
        @keys = [*0...enum.size]
      end

      return unless @p_margins.nil? || @keys.nil? || @keys.empty?

      raise ArgumentError, 'input structure must be a non-empty Hash or Array'
    end

    def sample
      pick = @random ? @random.rand : rand

      idx = @p_margins.find_index { |margin| pick < margin }
      idx ||= @p_margins.count - 1 # safe assignment if last margin was not good enough

      @keys[idx]
    end

    private

    def normalized_margins(array, skip_normalization)
      raise ArgumentError, 'weights can be only positive' if array.any?(&:negative?)

      probabilities = skip_normalization ? array : normalize_probabilities(array)
      incremental_margins probabilities
    end

    def normalize_probabilities(array)
      sum = array.inject(&:+).to_f

      array.map { |el| el / sum }
    end

    # convert probs like [0.1, 0.2, 0.3, 0.4]
    # to incremental margins [0.1, 0.3, 0.6, 1.0]
    def incremental_margins(array)
      start = 0.0
      margins = array.map do |v|
        res = v + start
        start = res

        res
      end

      raise 'normalized probabilities total is not 1' if (start - 1.0).abs > ERROR_ALLOWANCE

      margins
    end

  end

  def self.sample(enum, skip_normalization: false)
    Base.new(enum, skip_normalization: skip_normalization).sample
  end
end
