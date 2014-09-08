require 'html5_tokenizer/token_handler'

module Html5Tokenizer
  class Scanner
    include Html5Tokenizer::TokenHandler

    def initialize(html)
      @tokenizer = Tokenizer.new()
      @tokenizer.insert(html)
      @tokenizer.eof()
    end

    def process()
      @tokenizer.run do |token|
        handle_token(token)
      end
    end

  end
end
