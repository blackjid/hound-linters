require "jobs/eslint_review_job"

RSpec.describe EslintReviewJob do
  include LintersHelper

  context "when file with .js extention contains violations" do
    it "reports violations" do
      expect_violations_in_file(
        content: content,
        filename: "foo/test.js",
        violations: [
          {
            line: 2,
            message: "'hello' is defined but never used  no-unused-vars",
          },
          {
            line: 3,
            message: "Unexpected console statement       no-console",
          },
        ],
      )
    end
  end

  context "when file with .jsx extention contains violations" do
    it "reports violations" do
      expect_violations_in_file(
        content: "import React from 'react';",
        filename: "foo/test.jsx",
        violations: [
          {
            line: 1,
            message: "Parsing error: 'import' and 'export' may appear only with 'sourceType: module'",
          },
        ],
      )
    end
  end

  def content
    <<~JS
      'use strict';
      function hello() { }
      console.log('world')
    JS
  end
end
