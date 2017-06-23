# Trust You - Ruby Test

There is only one class in this repository that is responsible for parsing a string containing a comma separated list of associated resources to include with a request (http://jsonapi.org/format/#fetching-includes).

## Setup
```
gem install bundler
bundle install
```

## How to use it
Open `irb` and call the public instance methods from `IncludedResourceParams` class.
```ruby
require_relative 'included_resource_params'
included_resource_params = IncludedResourceParams.new('foo.bar.baz,foo,foo.bat,bar,foo.bar.baz.tar,rat.*,foo.bar.baz.tar.foo,tar')
included_resource_params.included_resources # => ["foo.bar.baz", "foo", "foo.bat", "bar", "foo.bar.baz.tar", "foo.bar.baz.tar.foo", "tar"]
included_resource_params.has_included_resources? # => true
included_resource_params.model_includes # => [{:foo=>[{:bar=>[{:baz=>[{:tar=>[:foo]}]}]}, :bat]}, :bar, :tar]
```

## Unit tests
I decided to use RSpec but I kept exactly the same test scenarios.
### Run RSpec
`bundle exec rspec --format documentation`

## Source code
[GitHub repository](https://github.com/lucasmoreno/trust_you_test)

## Why not codepen?
I decided not to use codepad because it does not support some features from newer Ruby versions like named parameters.
