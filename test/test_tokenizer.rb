require 'test/unit'
require 'html5_tokenizer'

class TokenizerTest < Test::Unit::TestCase
  def test_run_text
    tokenizer = Html5Tokenizer::Tokenizer::new()
    tokenizer.insert('foobar')
    tokenizer.run do |token|
      assert_equal :character, token.type
      assert_equal 'foobar', token.value
    end
  end

  def test_run_html
    tokenizer = Html5Tokenizer::Tokenizer::new()
    tokenizer.insert('<!doctype html><html><body><a><img src="http://test.com/img"/> An Image </a><!--End-->"')
    expecteds = [
      { :type => :doctype, :name => 'html', :public_missing => true, :public_id => '', :system_missing => true, :system_id => '', :force_quirks => false },
      { :type => :start_tag, :name => 'html', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :start_tag, :name => 'body', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :start_tag, :name => 'a', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :start_tag, :name => 'img', :ns => :ns_html, :attributes => {'src' => 'http://test.com/img'}, :self_closing => true },
      { :type => :character, :value => ' An Image ' },
      { :type => :end_tag, :name => 'a', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :comment, :value => 'End' },
    ]

    actuals = []
    tokenizer.run { |t| actuals << t }

    actuals.zip(expecteds).each do |actual, expected|
      expected.each { |k,v| assert_equal v, actual.send(k), "Test token #{actual.type}" }
    end
  end
end
