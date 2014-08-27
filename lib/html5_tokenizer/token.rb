module Html5Tokenizer
  class Token
    attr_accessor :type

    class Doctype < Token
      attr_accessor :name, :public_missing, :public_id, :system_missing, :system_id, :force_quirks

      def initialize(name, public_missing, public_id, system_missing, system_id, force_quirks)
        self.name = name
        self.public_missing = public_missing
        self.public_id = public_id
        self.system_missing = system_missing
        self.force_quirks
        self.type = :doctype
      end
    end

    class Tag < Token
      attr_accessor :ns, :name, :attributes, :self_closing

      def initialize(ns, name, attributes, self_closing)
        self.ns = ns
        self.name = name
        self.attributes = attributes
        self.self_closing = self_closing
        self.type = :tag
      end
    end

    class StartTag < Tag
      def initialize(*args)
        super(*args)
        self.type = :start_tag
      end
    end

    class EndTag < Tag
      def initialize(*args)
        super(*args)
        self.type = :end_tag
      end
    end

    class Comment < Token
      attr_accessor :value

      def initialize(value)
        self.value = value
        self.type = :comment
      end
    end

    class Character < Token
      attr_accessor :value

      def initialize(value)
        self.value = value
        self.type = :character
      end
    end

    class Eof < Token
      def initialize(value)
        self.type = :eof
      end
    end
  end
end
