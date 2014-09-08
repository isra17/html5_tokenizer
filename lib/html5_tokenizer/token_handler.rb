module Html5Tokenizer
  module TokenHandler
    def handle_token(token)
      case token.type
      when :doctype then handle_doctype(token)
      when :start_tag then handle_start_tag(token)
      when :end_tag then handle_end_tag(token)
      when :comment then handle_comment(token)
      when :character then handle_character(token)
      when :eof then handle_eof(token)
      else token
      end
    end

    def handle_doctype(token) token end
    def handle_start_tag(token) token end
    def handle_end_tag(token) token end
    def handle_comment(token) token end
    def handle_character(token) token end
    def handle_eof(token) token end
  end
end
