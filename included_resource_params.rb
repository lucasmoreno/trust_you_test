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
    parse_for_active_record_includes(included_resources)
  end

  private
  
  # @param resources [Array]
  # @param scope_elements [Array]
  # @return [Array]
  def parse_for_active_record_includes(resources, scope_elements = [])
    resources ||= included_resources
    return_value = []
    scope_elements ||= []
    resources.each do |resource|
      if resource.include?('.')
        key = resource[0..resource.index('.')-1].to_sym
        resto = resource[resource.index('.')+1..resource.length]
        hash_dessa_chave = scope_elements.find { |return_element| return_element.is_a?(Hash) && return_element.has_key?(key) }

        new_key = false
        if !hash_dessa_chave
          new_key = true
          scope_elements << { key => [] }
        end
        hash_dessa_chave = scope_elements.find { |return_element| return_element.is_a?(Hash) && return_element.has_key?(key) }

        parse_for_active_record_includes([resto], hash_dessa_chave[key])

        new_key ? return_value << hash_dessa_chave : return_value = [hash_dessa_chave]
      else
        scope_elements << resource.to_sym
        return_value = scope_elements
      end
    end
    return_value
  end
end
