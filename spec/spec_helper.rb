# frozen_string_literal: true

$LOAD_PATH.unshift "./lib"
require "staticky/files"
require "pathname"
require_relative "support/rspec"

%w[support].each do |dir|
  Dir[File.join(Dir.pwd, "spec", dir, "**", "*.rb")].each do |file|
    require_relative file unless file["support/warnings.rb"]
  end
end
