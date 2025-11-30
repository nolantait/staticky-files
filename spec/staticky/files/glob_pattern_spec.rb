# frozen_string_literal: true

require "staticky/files/glob_pattern"

RSpec.describe Staticky::Files::GlobPattern do
  describe "#expanded" do
    it "returns expanded patterns for braces" do
      pattern = described_class.new("src/{js,css}/**/*.{js,css}")
      expanded = pattern.expanded

      expect(expanded.map(&:pattern)).to contain_exactly(
        "src/js/**/*.js",
        "src/js/**/*.css",
        "src/css/**/*.js",
        "src/css/**/*.css"
      )
    end
  end
end
