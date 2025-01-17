# frozen_string_literal: true

require "rbconfig"

module RSpec
  module Helpers
    module OS
      private

      def with_operating_system(os)
        result = case host_os = RbConfig::CONFIG["host_os"]
                 when /linux/ then :linux
                 when /darwin/ then :macos
                 when /win32|mingw|bccwin|cygwin/ then :windows
                 else
                   raise "unkwnown OS: `#{host_os}'"
        end

        yield if result == os
      end
    end
  end
end

RSpec.configure do |config|
  config.include(RSpec::Helpers::OS)
end
