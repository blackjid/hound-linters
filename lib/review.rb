require "resque"
require "scss_lint"
require "ext/scss_lint/config.rb"
require "config_options"
require "jobs/completed_file_review_job"
require "jobs/report_invalid_config_job"

class Review
  COMMIT_SHA = "commit_sha".freeze
  CONFIG = "config".freeze
  CONTENT = "content".freeze
  DEFAULT_VIOLATIONS = [].freeze
  FILENAME = "filename".freeze
  LINTER_NAME = "scss".freeze
  PATCH = "patch".freeze
  PULL_REQUEST_NUMBER = "pull_request_number".freeze

  def self.run(attributes)
    new(attributes).run
  end

  def initialize(attributes)
    @attributes = attributes
    @config_options = ConfigOptions.new(attributes[CONFIG])
  end

  def run
    if config_options.valid?
      violations = review_file
      complete_file_review(violations)
    else
      report_invalid_config
    end
  end

  private

  attr_reader :config_options, :attributes

  def report_invalid_config
    Resque.enqueue(
      ReportInvalidConfigJob,
      pull_request_number: attributes.fetch(PULL_REQUEST_NUMBER),
      commit_sha: attributes.fetch(COMMIT_SHA),
      linter_name: LINTER_NAME,
    )
  end

  def review_file
    Dir.mktmpdir do |dir|
      Dir.chdir dir
      FileUtils.mkdir_p(File.dirname(filename))
      File.write(filename, content)
      File.write(".scss-lint.yml", config)
      regex = /\A
        (?<path>.+):
        (?<line_number>\d+)\s+
        \[(?<violation_level>\w)\]\s+
        (?<rule_name>\w+):\s+
        (?<message>.+)
        \n?
      \z/ox
      `scss-lint #{filename}`.each_line.map do |line|
        match_data = regex.match(line)

        if match_data
          {
            line: match_data[:line_number].to_i,
            message: match_data[:message],
          }
        end
      end.compact
    end
  end

  def create_tempfile
    filename = File.basename(attributes.fetch(FILENAME))
    Tempfile.create(filename) do |file|
      file.write(attributes.fetch(CONTENT))
      file.rewind

      yield(file)
    end
  end

  def complete_file_review(violations)
    Resque.enqueue(
      CompletedFileReviewJob,
      filename: attributes.fetch(FILENAME),
      commit_sha: attributes.fetch(COMMIT_SHA),
      pull_request_number: attributes.fetch(PULL_REQUEST_NUMBER),
      patch: attributes.fetch(PATCH),
      violations: violations,
    )
  end

  def filename
    attributes.fetch(FILENAME)
  end

  def content
    attributes.fetch(CONTENT)
  end

  def config
    attributes.fetch(CONFIG) do
      File.read(File.join(File.expand_path("../..", __FILE__), ConfigOptions::DEFAULT_CONFIG_FILE))
    end
  end
end
