require 'html5_tokenizer/token_handler'

module Html5Tokenizer
  class Rewriter
    include Html5Tokenizer::TokenHandler

    class TokenRewriter
      include Html5Tokenizer::TokenHandler

      def handle_doctype(token)
        html = ''
        html << '<!DOCTYPE'
        html << " #{token.name}" unless token.name.empty?
        html << " PUBLIC \"#{token.public_id}\"" unless token.public_missing
        html << " SYSTEM \"#{token.system_id}\"" unless token.system_missing
        html << '>'
      end

      def handle_start_tag(token)
        html = ''
        html << "<#{token.name}"
        html + handle_tag(token)
      end

      def handle_end_tag(token)
        html = ''
        html << "</#{token.name}"
        html << handle_tag(token)
      end

      def handle_tag(token)
        html = ''
        token.attributes.each do |k,v|
          html << " #{k}=\"#{v.gsub('"','&quot;')}\""
        end
        html << " /" if token.self_closing
        html << ">"
      end

      def handle_character(token)
        html = ''
        html << escape(token.value)
      end

      def handle_comment(token)
        html = ''
        html << "<!--#{token.value}-->"
      end

      def handle_eof(token)
        ''
      end

      private

      def escape(html)
        html.gsub('&', '&amp;').gsub('<','&lt;').gsub('>', '&gt;')
      end
    end

    def initialize(original_html)
      @tokenizer = Html5Tokenizer::Tokenizer.new
      @tokenizer.insert(original_html)
      @tokenizer.eof
      @token_rewriter = TokenRewriter.new
      @html = ''
    end

    def rewrite
      @tokenizer.run do |token|
        handle_token(token)
        @html << @token_rewriter.handle_token(token)
      end

      @html
    end
  end
end
