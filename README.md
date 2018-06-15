# WeightedSampler

Main repository is https://gitlab.com/alexey_b/weighted_sampler

Gitlab [![pipeline status](https://gitlab.com/alexey_b/weighted_sampler/badges/master/pipeline.svg)](https://gitlab.com/alexey_b/weighted_sampler/commits/master)[![coverage report](https://gitlab.com/alexey_b/weighted_sampler/badges/master/coverage.svg)](https://gitlab.com/alexey_b/weighted_sampler/commits/master) Travis [![Build Status](https://travis-ci.org/ababich/weighted_sampler.svg?branch=master)](https://travis-ci.org/ababich/weighted_sampler)

Weighted Sampler helps you to pick a random samples from a collection with defined probabilities or weights


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'weighted_sampler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install weighted_sampler

## Usage

Module or sampler instance modes available

### Module

```ruby
>> WeightedSampler.sample([P0, P1, ...])
=> INDEX
>> WeightedSampler.sample({K0 => P0, K1 => P1, ...})
=> Ki
```

#### Input as an Array

You can provide `Array` of probabilities in a form of weights for each option.

Equal probabilities: `[50, 50]` or `[1, 1]` or `[0.5, 0.5]`

Different probabilities: `[99, 1]`, or `[0.001, 0.1]` (index 1 is 100x times more likely to be chosen than 0)

If your input probabilies are not normalized `WeightedSampler` will do it for you

`OUTPUT` will be an index of selected value, so that you can match it to your more complex data structure

#### Input as an Hash

To simplify dome workflows you can provide `Hash` structure in a way

```ruby
{ K0 => P0, ...}
{ a: 1, b: 1, c: 2} # c has 0.5, a and b - 0.25
{ 0 => 50, 150 => 1} # 105 key is 50 times less probable to be picked
```

where `values` are probabilities with requirements similar to `Array` approach

`OUTPUT` in this case will be picked `key`

### Class (`::Base`)

Class is the *recommended* way to use of sampler becuase it's performance is ~10x better than Module

You need to initialize sampler:

```ruby
sampler = WeightedSampler::Base.new([P0, P1, ...])
# OR
sampler = WeightedSampler::Base.new({K0 => P0, K1 => P1, ...})
```

after that you can get samples via

`sampler.sample # => index (for Array) or key (for Hash)`

Input parameter to initialization of an instance are similar to Module use case.

Plus, you can you `seed` option for repeatable results

### Options

#### `skip_normalization`
**You do not have to normalize input probabilities**

But for some reason you may want to normalize yourself, for this
you have an option `skip_normalization`

```ruby
WeightedSampler.sample([...], skip_normalization: true)
WeightedSampler.sample({...}, skip_normalization: true)
```

if we will not be able to sum provided probabilities into `1` you'll get `RuntimeError` exception with some information about this

#### `seed` (¡ Class use case only !)

If you need to get repeatable sequence of samples you can initialize sampler with seed Integer (similar to ruby`s [Random](https://ruby-doc.org/core/Random.html#method-c-new)

```ruby
WeightedSampler::Base.new([...], seed: SEED)
WeightedSampler::Base.new([...], seed: SEED)
```

Please, note that if `seed` is not provided, sampler will use generic `rand` functionality without any seed initialization

### Performance

Once initialized, solution complexity is `O(n)`. [`Array#index`](https://ruby-doc.org/core/Array.html#method-i-index) is used to find a `rand` match to intervals (see [Math](#Math) section below).

Perfromance of this approach is acceptable.

### Math

Consider normalized probabilities `P0, P1, .., Pn, 𝚺Pi = 1, 0 <= i <= n`

To select random index `i` with these probabilities we convert them into half-open intervals `[0, P0)`, `[P0, P1)`, `[P0+P1, P2)` ... `[𝚺Pi, 1), 0 <= i < n` and place on a half-open interval `[0, 1)`

```
[<- P1 ->)[<-  P2  ->)    ...         [<-   Pn   ->)
[--------------------------------------------------)
                    ^- rand (sample pick)
```

As you can see any random value from `[0, 1)` will hin into one of the half-open intervals with probability equal to the "length" of the interval

`rand` (seeded or not) will does exactly what is needed and returns a value in the same half-open interval `[0, 1)`

*NOTE about Terminilogy and beauty in Ruby:* in ruby [Range](https://ruby-doc.org/core/Range.html) class with `...`   definition is equivalent to [half-open interval in the end](https://en.wikipedia.org/wiki/Interval_(mathematics)#Terminology) (i.e. `[0...1]` in Ruby is `[0, 1)` in math

*NOTE about precision and computer algebra ugliness:* in programming we cannot be sure that `𝚺Pi` will end up exactly equivalent to 1. And I do not like idea to use Ruby's [Rational](https://ruby-doc.org/core/Rational.html) due to performance implications and not much benefitss here

That's why `ERROR_ALLOWANCE = 10**-8` is accepted in normalization logic in WeightedSampler

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://gitlab.com/[USERNAME]/weighted_sampler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT)

## Code of Conduct

Everyone interacting in the WeightedSampler project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/weighted_sampler/blob/master/CODE_OF_CONDUCT.md)
