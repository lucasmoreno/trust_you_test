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

## Changes
 - Besides the implementation of the required methods, I decided to use RSpec for the unit tests.
 - One of the unit tests seems to be wrong, so I changed it from:
 ```ruby
def test_model_includes_multiple_three_level_resources
  assert IncludedResourceParams.new('foo.bar.baz,foo,foo.bar.bat,bar').model_includes == [{:foo => [{:bar => [:baz, :bat]}]}, :bar]
end
 ```
 to
 ```ruby
def test_model_includes_multiple_three_level_resources
  assert IncludedResourceParams.new('foo.bar.baz,foo,foo.bar.bat,bar').model_includes == [{:foo => [{:bar => [:baz, :foo, :bat]}]}, :bar]
end
 ```
 in RSpec:
 ```ruby
describe '#model_includes' do
  subject { parser.model_includes }
  context 'when it receives multiple three level resources' do
    let(:include_param) { 'foo.bar.baz,foo,foo.bar.bat,bar' }
    it { is_expected.to eq [{:foo => [{:bar => [:baz, :bat]}]}, :foo, :bar] }
  end
end
 ```

## Unit tests
### Install the gems
`bundle install`

### Run RSpec
`bundle exec rspec`
