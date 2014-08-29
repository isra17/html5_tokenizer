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

  def test_public_doctype
    tokenizer = Html5Tokenizer::Tokenizer::new()
    tokenizer.insert('<!DOCTYPE foo PUBLIC "public_location">')
    tokenizer.run do |token|
      assert_equal :doctype, token.type
      assert_equal 'foo', token.name
      assert_equal false, token.public_missing
      assert_equal 'public_location', token.public_id
      assert_equal true, token.system_missing
      assert_equal '', token.system_id
      assert_equal false, token.force_quirks
    end
  end

  def test_system_doctype
    tokenizer = Html5Tokenizer::Tokenizer::new()
    tokenizer.insert('<!DOCTYPE foo SYSTEM "system_location">')
    tokenizer.run do |token|
      assert_equal :doctype, token.type
      assert_equal 'foo', token.name
      assert_equal true, token.public_missing
      assert_equal '', token.public_id
      assert_equal false, token.system_missing
      assert_equal 'system_location', token.system_id
      assert_equal false, token.force_quirks
    end
  end

  def test_quirk_doctype
    tokenizer = Html5Tokenizer::Tokenizer::new()
    tokenizer.insert('<!doctype>"')
    tokenizer.run do |token|
      assert_equal :doctype, token.type
      assert_equal '', token.name
      assert_equal true, token.public_missing
      assert_equal '', token.public_id
      assert_equal true, token.system_missing
      assert_equal '', token.system_id
      assert_equal true, token.force_quirks
    end
  end
end
