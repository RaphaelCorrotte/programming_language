# frozen_string_literal: true

require File.expand_path("../../src/lexer", File.dirname(__FILE__))

def test(input)
  lexer = Lexer.new(input)
  lexer.tokenize
  input.split(/\s/).each_with_index do |keyword, index|
    expect(lexer.tokens[index]&.value).to eq(keyword) unless lexer.tokens[index]&.type == :eof
  end
end

RSpec.describe Lexer do
  it "initializes with an input" do
    input = "1 + 2"
    lexer = Lexer.new(input)
    expect(lexer.input).to eq(input)
  end

  it "recognizes string" do
    input = '"hello world"'
    lexer = Lexer.new(input)
    lexer.tokenize
    expect(lexer.tokens.first&.value).to eq(input.gsub(/"/, ""))
  end

  Hash[
    number: "1256",
    keywords: "if else elsif end def",
    plus: "+",
    minus: "-",
    "multiple tokens": "1 + 2 if - 125",
    equal: "=",
    negation: "!",
  ].each do |type, input|
    it "recognizes #{type}" do
      test(input)
    end
  end

  it "recognizes multiple punctuation" do
    input = "(){}[]"
    lexer = Lexer.new(input)
    lexer.tokenize
    input.split(//).each_with_index do |keyword, index|
      expect(lexer.tokens[index]&.value).to eq(keyword) unless lexer.tokens[index]&.type == :eof
      end
  end
end
