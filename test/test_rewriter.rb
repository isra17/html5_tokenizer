require 'test/unit'
require 'html5_tokenizer'

class TestRewriter < Test::Unit::TestCase

  class UpperCaseRewrite < Html5Tokenizer::Rewriter
    def handle_tag(token)
      token.name = token.name.capitalize
      new_attributes = {}
      token.attributes.each do |k,v|
        new_attributes[k.capitalize] = v.capitalize
      end
      token.attributes = new_attributes
    end

    alias_method :handle_start_tag, :handle_tag
    alias_method :handle_end_tag, :handle_tag

    def handle_text(token)
      token.value = token.value.capitalize
    end

    alias_method :handle_comment, :handle_text
    alias_method :handle_character, :handle_text
  end


  def test_rewriter
    actual = '<a b="c">d</e><!--f-->'
    expected = '<A B="C">D</E><!--F-->'
    assert_rewrites expected, actual
  end

  def assert_rewrites(expected, actual)
    rewriter = UpperCaseRewrite.new(actual)
    assert_equal expected, rewriter.rewrite
  end
end

