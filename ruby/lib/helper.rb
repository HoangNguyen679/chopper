# frozen_string_literal: true

# Helper functions
module Helper
  def to_snake_keys(value = self)
    case value
    when Array
      value.map { |v| to_snake_keys(v) }
    when Hash
      snake_hash(value)
    else
      value
    end
  end

  private

  def snake_hash(value)
    value.to_h { |k, v| [underscore_key(k), to_snake_keys(v)] }
  end

  def underscore_key(key)
    case key
    when Symbol
      underscore(key.to_s).to_sym
    when String
      underscore(key)
    else
      key
    end
  end

  def underscore(string)
    @__memoize_underscore ||= {}

    return @__memoize_underscore[string] if @__memoize_underscore[string]

    @__memoize_underscore[string] =
      string.tr('::', '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
    @__memoize_underscore[string]
  end
end

class Hash
  include Helper
end
