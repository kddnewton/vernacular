# Vernacular

[![Build Status](https://github.com/kddeisz/vernacular/workflows/Main/badge.svg)](https://github.com/kddeisz/vernacular/actions)
[![Gem Version](https://img.shields.io/gem/v/vernacular.svg)](https://rubygems.org/gems/vernacular)

Allows extending ruby's syntax and compilation process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vernacular'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vernacular

## Usage

At the very beginning of your script or application, require `vernacular`. Then, configure your list of modifiers so that `vernacular` knows how to modify your code before it is compiled.

For example,

```ruby
Vernacular.configure do |config|
  pattern = /~n\(([\d\s+-\/*\(\)]+?)\)/
  modifier =
    Vernacular::RegexModifier.new(pattern) do |match|
      eval(match[3..-2])
    end
  config.add(modifier)
end
```

will extend Ruby syntax to allow `~n(...)` symbols which will evaluate the interior expression as one number. This reduces the number of objects and instructions allocated for a given segment of Ruby, which can improve performance and memory.

### `Modifiers`

Modifiers allow you to modify the source of the Ruby code before it is compiled by injecting themselves into the require chain through `RubyVM::InstructionSequence::load_iseq`. They can be any of the preconfigured modifiers built into `Vernacular`, or they can just be a plain ruby class that responds to the method `modify(source)` where `source` is a string of code. The method should returned the modified source.

### `RegexModifier`

Regex modifiers take the same arguments as `String#gsub`. Either configure them with a string, as in:

```ruby
Vernacular::RegexModifier.new(/~u\((.+?)\)/, 'URI.parse("\1")')
```

or configure them using a block, as in:

```ruby
Vernacular::RegexModifier.new(pattern) do |match|
  eval(match[3..-2])
end
```

### `ASTModifier`

For access to and documentation on the `ASTModifier`, check out the [`vernacular-ast`](https://github.com/kddeisz/vernacular-ast) gem.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kddeisz/vernacular.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
