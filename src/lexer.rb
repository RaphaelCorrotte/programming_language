# frozen_string_literal: false

require File.expand_path("token", File.dirname(__FILE__))

class Lexer
  CHARS_TYPE = Token::TOKENS.dup.merge!(string: /"/).freeze
  attr_reader :input, :current_char, :position, :tokens

  def initialize(input)
    @input = input
    @position = 0
    @current_char = @input[@position]
    @tokens = []
  end

  def tokenize
    @tokens << next_token
    while source_uncompleted?
      next advance if @current_char.match(/\s/)

      @tokens << next_token
      advance
      break if @current_char.nil?
    end
    @tokens << Token.new(:eof, "", [@position, @position])
  end

  def next_token
    skip_spaces!
    position = @position
    token = manage(@current_char)
    Token.new(token[:type], token[:value], [position, @position])
  end

  def skip_spaces!
    advance while @current_char&.match?(/\s/)
  end

  def advance(count = 1)
    @position += count
    @current_char = @input[@position]
  end

  def peek
    return nil if (@position + 1) >= @input.length

    @input[@position + 1]
  end

  def source_completed?
    @input[@position].nil?
  end

  def source_uncompleted?
    !source_completed?
  end

  def manage(char)
    raise "Invalid character: #{char}" unless CHARS_TYPE.values.any? { |v| char.match?(v) }

    type = CHARS_TYPE.select { |_, v| char.match?(v) }.keys.first
    value = ""
    if %i[dot space negation equal plus minus left_parenthesis right_parenthesis left_brace right_brace left_bracket right_bracket].include?(type)
      advance if @position.zero?

      return Hash[type:, value: char]
    end

    case type
    when :string
      until peek&.match?(CHARS_TYPE[:string])
        value << advance
        raise "Invalid string" if peek.nil?
      end
      advance(2)
    when :number
      value << char
      while @current_char.match?(/\d/) && source_uncompleted?
        break unless peek

        value << peek if peek&.match?(/\d/)
        advance
      end
    else
      value << char
      while peek&.match?(/[^()\[\]{}\s\.]/)
        break unless peek

        value << advance
      end
      advance unless @current_char.match?(/\s/)

      if value.match?(Token::TOKENS[:keyword])
        type = :keyword
      elsif value.match?(Token::TOKENS[:identifier])
        type = :identifier
      end
    end
    Hash[
      type:,
      value:
    ]
  end
end
