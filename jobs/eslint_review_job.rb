require "resque"
require "linters/runner"
require "linters/eslint/options"

class EslintReviewJob
  @queue = :eslint_review

  def self.perform(attributes)
    Linters::Runner.call(
      linter_options: Linters::Eslint::Options.new,
      attributes: attributes,
    )
  end
end
