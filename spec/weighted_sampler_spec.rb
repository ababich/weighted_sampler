# frozen_string_literal: true

RSpec.describe WeightedSampler do
  it 'has a version number' do
    expect(WeightedSampler::VERSION).not_to be nil
  end

  context 'sampler' do
    limit_power = 20
    limit = 2**limit_power
    module_sampler = ->(enum) { WeightedSampler.sample(enum) }
    class_sampler = ->(enum) { WeightedSampler::Base.new(enum).sample }

    [
      ['module', module_sampler],
      ['class', class_sampler]
    ].each do |ctx, sampler|
      context ctx do
        array = -> { Array.new(10) { rand(limit) } }
        hash = -> { array.call.map { |e| [e, e] }.to_h }

        [
          ['on array', array],
          ['on hash', hash]
        ].each do |ctx_data, enumerator|

          context ctx_data do
            let(:samples) { enumerator.call }
            let(:sample) { sampler.call(samples) }

            it { expect(sample).to be_a(Numeric) }
            it { expect(sample).to be < limit }

            context 'sample for collection' do
              let(:sample_keys) do
                samples.is_a?(Hash) ? samples.keys : [*0...samples.size]
              end

              it { limit_power.times { expect(sample_keys).to include(sampler.call(samples)) } }
            end
          end
        end
      end
    end

    context 'distributions' do
      let(:test_count) { 200_000 }
      let(:delta) { 0.005 }

      let(:h_samples) { a_samples.map { |e| [e, e] }.to_h }

      context 'for one element' do
        let(:a_samples) { [1] }

        context 'with module' do
          it { test_count.times { expect(WeightedSampler.sample(a_samples)).to eq(0) } }
          it { test_count.times { expect(WeightedSampler.sample(h_samples)).to eq(h_samples.keys.first) } }
        end

        context 'with class' do
          it do
            sampler = WeightedSampler::Base.new(a_samples)
            test_count.times { expect(sampler.sample).to eq(0) }
          end

          it do
            sampler = WeightedSampler::Base.new(h_samples)
            test_count.times { expect(sampler.sample).to eq(h_samples.keys.first) }
          end
        end
      end

      context 'for euqal probability' do
        let(:a_samples) { [1] * 7 }

        it 'with module' do
          picks = Hash.new(0)
          test_count.times { picks[WeightedSampler.sample(a_samples)] += 1 }

          expect(picks.values.inject(&:+)).to eq(test_count)
          target_p = 1.0 / a_samples.count

          picks.each_value { |v| expect(v.to_f / test_count).to be_within(delta).of(target_p) }
        end

        it 'with class' do
          picks = Hash.new(0)
          sampler = WeightedSampler::Base.new(a_samples)
          test_count.times { picks[sampler.sample] += 1 }

          expect(picks.values.inject(&:+)).to eq(test_count)
          target_p = 1.0 / a_samples.count

          picks.each_value { |v| expect(v.to_f / test_count).to be_within(delta).of(target_p) }
        end
      end

      context 'for extreme probabilities' do
        let(:a_samples) { [999, 1] }

        it 'with module' do
          picks = Hash.new(0)
          test_count.times { picks[WeightedSampler.sample(a_samples)] += 1 }

          expect(picks.values.inject(&:+)).to eq(test_count)
          target_p = 0.001

          a_samples.size.times do |i|
            expect(picks[i].to_f / test_count).to be_within(delta).of(target_p * a_samples[i])
          end
        end

        it 'with class' do
          picks = Hash.new(0)
          sampler = WeightedSampler::Base.new(a_samples)
          test_count.times { picks[sampler.sample] += 1 }

          expect(picks.values.inject(&:+)).to eq(test_count)
          target_p = 0.001

          a_samples.size.times do |i|
            expect(picks[i].to_f / test_count).to be_within(delta).of(target_p * a_samples[i])
          end
        end
      end

    end


    context 'input params' do
      context 'raise ArgumentError' do
        it { expect { WeightedSampler.sample(nil) }.to raise_error(ArgumentError) }
        it { expect { WeightedSampler::Base.new(nil).sample }.to raise_error(ArgumentError) }

        it { expect { WeightedSampler.sample([]) }.to raise_error(RuntimeError, /total is not 1/) }
        it { expect { WeightedSampler::Base.new([]).sample }.to raise_error(RuntimeError, /total is not 1/) }

        it { expect { WeightedSampler.sample({}) }.to raise_error(RuntimeError, /total is not 1/) }
        it { expect { WeightedSampler::Base.new({}).sample }.to raise_error(RuntimeError, /total is not 1/) }
      end

      context 'seed repeatability' do
        let(:samples) { [1] * 200 }
        let(:test_count) { 5000 }
        context 'without seed different' do
          it 'for module' do
            picks0 = (0..test_count).to_a.map { WeightedSampler.sample(samples) }
            picks1 = (0..test_count).to_a.map { WeightedSampler.sample(samples) }

            expect(picks0).not_to eq(picks1)
            expect(picks0.sort).not_to eq(picks1.sort) # ordered check too
          end

          it 'for class' do
            sampler0 = WeightedSampler::Base.new(samples)
            sampler1 = WeightedSampler::Base.new(samples)
            picks0 = (0..test_count).to_a.map { sampler0.sample }
            picks1 = (0..test_count).to_a.map { sampler1.sample }

            expect(picks0).not_to eq(picks1)
            expect(picks0.sort).not_to eq(picks1.sort) # ordered check too
          end
        end

        it 'with different seeds' do
          sampler0 = WeightedSampler::Base.new(samples, seed: 1)
          sampler1 = WeightedSampler::Base.new(samples, seed: 2)
          picks0 = (0..test_count).to_a.map { sampler0.sample }
          picks1 = (0..test_count).to_a.map { sampler1.sample }

          expect(picks0).not_to eq(picks1)
          expect(picks0.sort).not_to eq(picks1.sort) # ordered check too
        end

        it 'with same seed' do
          sampler0 = WeightedSampler::Base.new(samples, seed: 1)
          sampler1 = WeightedSampler::Base.new(samples, seed: 1)
          picks0 = (0..test_count).to_a.map { sampler0.sample }
          picks1 = (0..test_count).to_a.map { sampler1.sample }

          expect(picks0).to eq(picks1)
        end
      end

      context 'skip normalization' do
        it { expect { WeightedSampler.sample([0], skip_normalization: true) }.to raise_error(RuntimeError, /total is not 1/) }
        it { expect { WeightedSampler.sample([0.1, 0.2], skip_normalization: true) }.to raise_error(RuntimeError, /total is not 1/) }
        it { expect { WeightedSampler.sample([0.5, 0.5], skip_normalization: true) }.not_to raise_error }

        it { expect { WeightedSampler::Base.new([0], skip_normalization: true).sample }.to raise_error(RuntimeError, /total is not 1/) }
        it { expect { WeightedSampler::Base.new([0.1, 0.2], skip_normalization: true).sample }.to raise_error(RuntimeError, /total is not 1/) }
        it { expect { WeightedSampler::Base.new([0.5, 0.5], skip_normalization: true).sample }.not_to raise_error }
      end
    end
  end

  context 'private method' do
    let(:array) { [1] }
    let(:sampler) { WeightedSampler::Base.new(array) }

    context 'normalized_margins' do
      it { expect { sampler.send(:normalized_margins, [], false) }.to raise_error(RuntimeError, /total is not 1/) }
      it { expect { sampler.send(:normalized_margins, [1, -1], false) }.to raise_error(ArgumentError, /only positive/) }

      it { expect(sampler.send(:normalized_margins, [1, 1], false)).to eq([0.5, 1]) }
      it { expect(sampler.send(:normalized_margins, [1, 0], true)).to eq([1, 1]) }
    end


    context 'normalize_probabilities' do
      it { expect(sampler.send(:normalize_probabilities, [])).to eq([]) }
      it { expect(sampler.send(:normalize_probabilities, [1])).to eq([1]) }
      it { expect(sampler.send(:normalize_probabilities, [1, 1])).to eq([0.5, 0.5]) }
      it { expect(sampler.send(:normalize_probabilities, [1, 9])).to eq([0.1, 0.9]) }
      it { expect(sampler.send(:normalize_probabilities, [1] * 100)).to eq([1.0 / 100] * 100) }
      it { expect(sampler.send(:normalize_probabilities, [0.001, 0.199])).to eq([0.005, 0.995]) }
    end

    context 'array_to_ranges' do
      it { expect { sampler.send(:incremental_margins, []) }.to raise_error(RuntimeError, /total is not 1/) }
      it { expect { sampler.send(:incremental_margins, [1, 1]) }.to raise_error(RuntimeError, /total is not 1/) }

      it { expect(sampler.send(:incremental_margins, [0.5, 0.5])).to eq([0.5, 1]) }
      it { expect(sampler.send(:incremental_margins, [1, 0])).to eq([1, 1]) }
      it { expect(sampler.send(:incremental_margins, [0, 1])).to eq([0, 1]) }
    end
  end
end
