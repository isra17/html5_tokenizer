require 'test/unit'
require 'html5_tokenizer'

class TokenizerTest < Test::Unit::TestCase
  def tokens(tokenizer)
    tokens = []
    tokenizer.run { |t| tokens << t }
    tokens
  end

  def tokenize(html)
    tokenizer = Html5Tokenizer::Tokenizer::new()
    tokenizer.insert(html)
    tokenizer.eof()
    tokens(tokenizer)
  end

  def assert_tokens(expecteds, actuals)
    actuals.zip(expecteds).each do |actual, expected|
      expected.each { |k,v| assert_equal v, actual.send(k), "Test token #{actual}" }
    end
  end

  def test_run_text
    token = tokenize('foobar').first
    assert_equal :character, token.type
    assert_equal 'foobar', token.value
  end

  def test_run_html
    actuals = tokenize('<!doctype html><html><body><a><img src="http://test.com/img"/> An Image </a><!--End-->')
    expecteds = [
      { :type => :doctype, :name => 'html', :public_missing => true, :public_id => '', :system_missing => true, :system_id => '', :force_quirks => false },
      { :type => :start_tag, :name => 'html', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :start_tag, :name => 'body', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :start_tag, :name => 'a', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :start_tag, :name => 'img', :ns => :ns_html, :attributes => {'src' => 'http://test.com/img'}, :self_closing => true },
      { :type => :character, :value => ' An Image ' },
      { :type => :end_tag, :name => 'a', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :comment, :value => 'End' },
      { :type => :eof }
    ]

    assert_tokens(expecteds, actuals)
  end

  def test_public_doctype
    actuals = tokenize('<!DOCTYPE foo PUBLIC "public_location">')
    expecteds = [{ :type => :doctype, :name => 'foo',
                   :public_missing => false, :public_id => 'public_location',
                   :system_missing => true, :system_id => '',
                   :force_quirks => false },
                 { :type => :eof }]

    assert_tokens(expecteds, actuals)
  end

  def test_system_doctype
    actuals = tokenize('<!DOCTYPE foo SYSTEM "system_location">')
    expecteds = [{ :type => :doctype, :name => 'foo',
                   :public_missing => true, :public_id => '',
                   :system_missing => false, :system_id => 'system_location',
                   :force_quirks => false },
                 { :type => :eof }]

    assert_tokens(expecteds, actuals)
  end

  def test_quirk_doctype
    actuals = tokenize('<!DOCTYPE>')
    expecteds = [{ :type => :doctype, :name => '',
                   :public_missing => true, :public_id => '',
                   :system_missing => true, :system_id => '',
                   :force_quirks => true },
                 { :type => :eof }]

    assert_tokens(expecteds, actuals)
  end

  def test_tag_ns
    actuals = tokenize(%q{<a:a/><b a=a b="b" c='c'></a/></b>})
    expecteds = [
      { :type => :start_tag, :name => 'a:a', :ns => :ns_html, :attributes => {}, :self_closing => true },
      { :type => :start_tag, :name => 'b', :ns => :ns_html, :attributes => {'a'=>'a','b'=>'b','c'=>'c'}, :self_closing => false },
      { :type => :end_tag, :name => 'a', :ns => :ns_html, :attributes => {}, :self_closing => true },
      { :type => :end_tag, :name => 'b', :ns => :ns_html, :attributes => {}, :self_closing => false },
      { :type => :eof },
    ]

    assert_tokens(expecteds, actuals);
  end

  def test_reentrant_tokenize
    tokenizer = Html5Tokenizer::Tokenizer::new()
    tokenizer.insert('<!--<a b="c">-->')
    tokenizer.run do |token|
      assert_equal :comment, token.type
      assert_equal '<a b="c">', token.value
      inner_token = tokenize(token.value).first
      assert_equal :start_tag, inner_token.type
      assert_equal 'a', inner_token.name
      assert_equal ({'b'=>'c'}), inner_token.attributes
    end
  end
end
