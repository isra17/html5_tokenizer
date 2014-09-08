require 'test/unit'
require 'html5_tokenizer'

class TestScanner < Test::Unit::TestCase
  class AssertScanner < Html5Tokenizer::Scanner
    attr_accessor :result

    def initialize(test, *args)
      super(*args)
      @test = test
      self.result = []
    end

    def handle_doctype(token)
      @test.assert_equal :doctype, token.type
      self.result << token.type
    end

    def handle_start_tag(token)
      @test.assert_equal :start_tag, token.type
      self.result << token.type
    end

    def handle_end_tag(token)
      @test.assert_equal :end_tag, token.type
      self.result << token.type
    end

    def handle_character(token)
      @test.assert_equal :character, token.type
      self.result << token.type
    end

    def handle_comment(token)
      @test.assert_equal :comment, token.type
      self.result << token.type
    end
  end

  def test_scanner
    expected = [:doctype, :start_tag, :end_tag, :character, :comment]
    scanner = AssertScanner.new(self, '<!doctype><tag></tag>text<!--comment-->')
    scanner.run()
    assert_equal expected, scanner.result
  end
end

