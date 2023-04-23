# frozen_string_literal: true

class Token
  TOKENS = Hash[
    string: /./,
    dot: /\./,
    space: /\s/,
    number: /\d/,
    plus: /\+/,
    minus: /-/,
    nil: /nil/,
    newline: /\n/,
    keyword: /\A(if|else|elsif|end|def)\z/,
    equal: /=/,
    negation: /!/,
    left_parenthesis: /\(/,
    right_parenthesis: /\)/,
    left_brace: /\{/,
    right_brace: /}/,
    left_bracket: /\[/,
    right_bracket: /\]/,
    identifier: /[a-z|A-Z]+\d*[!|?]?/,
    eof: /\z/,
  ].freeze
  attr_reader :type, :value, :position

  def initialize(type, value, position)
    raise "Invalid token type: #{type}" unless TOKENS.key?(type)

    @type = type
    @value = value
    raise "Invalid value for token type #{type}: #{value.inspect}" unless value.to_s =~ TOKENS[type]

    @position = position
  end

  def length
    (@position[0] - @position[1]).abs + 1
  end

  def method_missing(name, *args)
    if name.end_with?("?") && TOKENS.key?(name[0..-2]&.to_sym)
      type == name[0..-2]&.to_sym
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    name.end_with?("?") && TOKENS.key?(name[0..-2]&.to_sym) || super
  end

  private :method_missing
end
