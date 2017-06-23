# Trust You - Ruby Test

There is only one class in this repository that is responsible for parsing a string containing a comma separated list of associated resources to include with a request (http://jsonapi.org/format/#fetching-includes).

## How to use it
Open `irb` and use the public methods.
```ruby
require_relative 'included_resource_params'
included_resource_params = IncludedResourceParams.new(include_param: 'foo.bar.baz,foo')
included_resource_params.included_resources # => ["foo.bar.baz", "foo"]
included_resource_params.has_included_resources? # => true
included_resource_params.model_includes # => [{:foo=>[{:bar=>[:baz]}]}, :foo]
```

## Main Changes
 - RSpec for unit tests.

## Unit tests
### Install the gems
`bundle install`

### Run RSpec
`bundle exec rspec`
