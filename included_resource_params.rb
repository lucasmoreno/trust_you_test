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
  # @!attribute [r] include_param
  #   @return [String]
  attr_reader :include_param

  # @param include_param [String]
  def initialize(include_param:)
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
      include_param ? include_param.split(',').reject { |param| param.match(/\*/) } : []
    end
  end

  def rejected_characters
    @rejected_characters ||= ['\*']
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
    parse_for_active_record_includes(included_resources.uniq)
  end

  private
  
  # @param resources [Array<String>]
  # @param scope_elements [Array]
  # @return [Array]
  def parse_for_active_record_includes(resources, scope_elements = [])
    resources.each do |resource|
      if matches = resource.match(/^(?<key>.+?)\.(?<ending>.+)$/)
        key = matches[:key].to_sym
        ending = matches[:ending]
        # element_hash = scope_elements.find { |element| element.is_a?(Hash) && element.has_key?(key) }
        element_hash = find_hash_with_key(scope_elements, key)

        if !element_hash
          element_hash = { key => [] }
          scope_elements << element_hash
        end

        parse_for_active_record_includes([ending], element_hash[key])
      else
        scope_elements << resource.to_sym
      end
    end
    scope_elements
  end

  # @param array [Array]
  # @param key [String]
  # @return [Hash, nil]
  def find_hash_with_key(array, key)
    array.find { |element| element.is_a?(Hash) && element.has_key?(key) }
  end
end
