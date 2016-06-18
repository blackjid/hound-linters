require "linters/eslint/tokenizer"

module Linters
  module Eslint
    class Options
      def command(filename)
        path = File.join(File.dirname(__FILE__), "../../..")
        cmd = "/node_modules/eslint/bin/eslint.js #{filename}"
        File.join(path, cmd)
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
