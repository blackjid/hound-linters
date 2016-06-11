require "linters/eslint/tokenizer"

module Linters
  module Eslint
    class Options
      def command
        path = File.join(File.dirname(__FILE__), "../../..")
        File.join(path, "/node_modules/eslint/bin/eslint.js .")
      end

      def config_filename
        ".eslintrc"
      end

      def default_config_path
        "config/eslintrc"
      end

      def tokenizer
        Tokenizer.new
      end
    end
  end
end
