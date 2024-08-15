# frozen_string_literal: true

module Staticky
  class Files
    class Adapter
      def self.call(memory:)
        if memory
          require_relative "memory_file_system"
          MemoryFileSystem.new
        else
          require_relative "file_system"
          FileSystem.new
        end
      end
    end
  end
end
