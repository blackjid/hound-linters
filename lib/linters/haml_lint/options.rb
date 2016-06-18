require "linters/haml_lint/tokenizer"

module Linters
  module HamlLint
    class Options
      def command(filename)
        "haml-lint #{filename}"
      end

      def config_filename
        ".haml-lint.yml"
      end

      def default_config_path
        "config/haml.yml"
      end

      def tokenizer
        Tokenizer.new
      end
    end
  end
end
