module Linters
  module Eslint
    class Tokenizer
      VIOLATION_REGEX = /\A
        (?<line_number>.+):
        (?<column_number>\d+)\s+
        (?<violation_level>\w+)\s+
        (?<message>.+)
        \n?
      \z/x

      def parse(text)
        text.split("\n").map { |line| tokenize(line) }.compact
      end

      private

      def tokenize(line)
        matches = VIOLATION_REGEX.match(line)

        if matches
          {
            line: matches[:line_number].to_i,
            message: matches[:message],
          }
        end
      end
    end
  end
end
