require 'html5_tokenizer'

t = Html5Tokenizer::Tokenizer.new
t.insert('<!DOCTYPE html> <img src="test" asd=fsd>asd <bà\ré/> </a>   <!-- comments -->')
t.run do |token|
  if token
    case token.type
    when :doctype
      print "doctype: #{token.name}\n"
    when :start_tag
      print "start tag: #{token.name}, #{token.attributes.to_s}\n"
    when :end_tag
      print "end tag: #{token.name}, #{token.attributes.to_s}\n"
    when :comment
      print "comment: #{token.value}\n"
    when :character
      print "character: #{token.value}\n"
    when :eof
      print "eof\n"
    end
  end
end
