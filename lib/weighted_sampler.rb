# frozen_string_literal: true

require 'weighted_sampler/version'
module WeightedSampler

  # sum of floats are never stable enough to guarantee exact equality to 1
  ERROR_ALLOWANCE = 10**-8

  class Base

    def initialize(enum, seed: nil, skip_normalization: false)
      @random = Random.new(seed) unless seed.nil?

      if enum.is_a?(Hash)
        @p_ranges = normalized_ranges(enum.values, skip_normalization)
        @keys = enum.keys
      elsif enum.is_a?(Array)
        @p_ranges = normalized_ranges(enum, skip_normalization)
        @keys = [*0...enum.size]
      end

      return unless @p_ranges.nil? || @keys.nil? || @keys.empty?
      raise ArgumentError, 'input structure must be a non-empty Hash or Array'
    end

    def sample
      pick = @random ? @random.rand : rand

      idx = @p_ranges.index { |range| range.include? pick }
      @keys[idx] if idx
    end

    private

    def normalized_ranges(array, skip_normalization)
      raise ArgumentError, 'weights can be only positive' if array.any?(&:negative?)

      probabilities = array
      probabilities = normalize_probabilities(probabilities) unless skip_normalization

      array_to_ranges probabilities
    end

    def normalize_probabilities(array)
      sum = array.inject(&:+).to_f

      array.map { |el| el / sum }
    end

    def array_to_ranges(array)
      start = 0.0
      ranges = array.map do |v|
        p_start = start
        start += v

        (p_start...v + p_start)
      end

      raise 'normalized probabilities total is not 1' if (start - 1.0).abs > ERROR_ALLOWANCE

      ranges
    end

  end

  def self.sample(enum, skip_normalization: false)
    Base.new(enum, skip_normalization: skip_normalization).sample
  end
end
