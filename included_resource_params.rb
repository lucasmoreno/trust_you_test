##
# The IncludedResourceParams class is responsible for parsing a string containing
# a comma separated list of associated resources to include with a request. See
# http://jsonapi.org/format/#fetching-includes for additional details although
# this is not required knowledge for the task at hand.
#
# Our API requires specific inclusion of related resourses - that is we do NOT
# want to support wildcard inclusion (e.g. `foo.*`)
#
# The IncludedResourceParams class has three public methods making up its API.
#
# [included_resources]
#   returns an array of non-wildcard included elements.
# [has_included_resources?]
#   Returns true if our supplied param has included resources, false otherwise.
# [model_includes]
#   returns an array suitable to supply to ActiveRecord's `includes` method
#   (http://guides.rubyonrails.org/active_record_querying.html#eager-loading-multiple-associations)
#   The included_resources should be transformed as specified in the unit tests
#   included herein.
#
# All three public methods have unit tests written below that must pass. You are
# free to add additional classes/modules as necessary and/or private methods
# within the IncludedResourceParams class.
#
# Feel free to use the Ruby standard libraries available on codepad in your
# solution.
#
# Create your solution as a private fork, and send us the URL.
#
class IncludedResourceParams
  RESOURCES_SEPARATOR_CHAR = ','
  RESOURCES_REJECTED_CHARS = %w(\*)

  # @!attribute [r] include_param
  #   @return [String]
  attr_reader :include_param

  # @param include_param [String]
  def initialize(include_param)
    @include_param = include_param
  end

  ##
  # Does our IncludedResourceParams instance actually have any valid included
  # resources after parsing?
  #
  # @return [Boolean] whether this instance has included resources
  def has_included_resources?
    @has_included_resources ||= included_resources.any?
  end

  ##
  # Fetches the included resourcs as an Array containing only non-wildcard
  # resource specifiers.
  #
  # @example nil
  #   IncludedResourceParams.new(nil).included_resources => []
  #
  # @example "foo,foo.bar,baz.*"
  #   IncludedResourceParams.new("foo,bar,baz.*").included_resources => ["foo", "foo.bar"]
  #
  # @return [Array<String>] an Array of Strings parsed from the include param with
  # wildcard includes removed
  def included_resources
    @included_resources ||= begin
      return [] unless include_param

      include_param.split(RESOURCES_SEPARATOR_CHAR).reject { |resource| invalid_resource?(resource) }
    end
  end

  ##
  # Converts the resources to be included from their JSONAPI representation to
  # a structure compatible with ActiveRecord's `includes` methods. This can/should
  # be an Array in all cases. Does not do any verification that the resources
  # specified for inclusion are actual ActiveRecord classes.
  #
  # @example nil
  #   IncludedResourceParams.new(nil).model_includes => []
  #
  # @example "foo"
  #   IncludedResourceParams.new("foo").model_includes => [:foo]
  #
  # @see Following unit tests
  #
  # @return [Array] an Array of Symbols and/or Hashes compatible with ActiveRecord
  # `includes`
  def model_includes
    @model_includes ||= parse_for_active_record_includes(resources: included_resources.uniq)
  end

  private

  ##
  # Check if the given resource have any invalid character
  #
  # @param resource [String]
  # @return [Boolean]
  def invalid_resource?(resource)
    !!resource.match(rejected_characters_regexp)
  end

  ##
  # A regexp used to ignore resources with invalid characters in #included_resources return
  #
  # @return [Regexp]
  def rejected_characters_regexp
    @rejected_characters_regexp ||= %r{(#{RESOURCES_REJECTED_CHARS.join('|')})}
  end

  ##
  # Recursively, parses the given resources to ActiveRecord's `includes` method format.
  #
  # @param resources [Array<String>] an Array with resources to be parsed
  # @param parent_relationships [Array<Object>] an Array contaning the relationships from the previous recursion iteration
  # @return [Array] an Array of Symbols and/or Hashes compatible with ActiveRecord's `includes` method
  def parse_for_active_record_includes(resources:, parent_relationships: [])
    resources.each do |resource|
      if matches = resource.match(/^(?<relationship_name>.+?)\.(?<nested_relationships>.+)$/)
        relationship_name = matches[:relationship_name].to_sym
        nested_relationships = matches[:nested_relationships]

        # To ensure that it won't return an Array with repeated relationships. e.g. [:foo, {foo: [:bar]}]
        parent_relationships.delete(relationship_name)

        current_relationships = find_hash_with_key(array: parent_relationships, key: relationship_name)

        if !current_relationships
          current_relationships = { relationship_name => [] }
          parent_relationships << current_relationships
        end

        parse_for_active_record_includes(resources: [nested_relationships], parent_relationships: current_relationships[relationship_name])
      else
        relationship_name = resource.to_sym
        unless find_hash_with_key(array: parent_relationships, key: relationship_name)
          parent_relationships << relationship_name
        end
      end
    end
    parent_relationships
  end

  ##
  # Finds the Hash with the given `key` in the given `array`.
  #
  # @param array [Array] an Array of Symbols and/or Hashes
  # @param key [String] the `key` to be found
  # @return [Hash, nil] the Hash which contains the given `key`
  def find_hash_with_key(array:, key:)
    array.find { |element| element.is_a?(Hash) && element.has_key?(key) }
  end
end
