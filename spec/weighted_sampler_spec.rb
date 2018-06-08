# frozen_string_literal: true

RSpec.describe WeightedSampler do
  it 'has a version number' do
    expect(WeightedSampler::VERSION).not_to be nil
  end

  context 'sampler' do
    limit_power = 20
    limit = 2**limit_power
    array = -> { Array.new(10) { rand(limit) } }
    hash = -> { array.call.each_slice(2).to_h }
    module_sampler = ->(enum) { WeightedSampler.sample(enum) }
    class_sampler = ->(enum) { WeightedSampler::Base.new(enum).sample }

    [
      ['module on array', array, module_sampler ],
      ['module on hash', hash, module_sampler ],
      ['class on array', array, class_sampler ],
      ['class on hash', hash, class_sampler ]
    ].each do |ctx, enumerator, sampler|
      context ctx do
        let(:samples) { enumerator.call }
        let(:sample) { sampler.call(samples) }

        it { expect(sample).to be_a(Numeric) }
        it { expect(sample).to be < limit }

        context 'sample for collection' do
          let(:sample_keys) do
            samples.is_a?(Hash) ? samples.keys : [*0...samples.size]
          end

          limit_power.times { it { expect(sample_keys).to include(sampler.call(samples)) } }
        end
      end
    end
  end
end
