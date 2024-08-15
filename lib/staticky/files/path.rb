# frozen_string_literal: true

module Staticky
  class Files
    # Cross Operating System path
    #
    # It's used by the memory adapter to ensure that hardcoded string paths
    # are transformed into portable paths that respect the Operating System
    # directory separator.
    module Path
      SEPARATOR = ::File::SEPARATOR
      EMPTY_TOKEN = ""

      class << self
        # Transform the given path into a path that respect the Operating System
        # directory separator.
        #
        # @param path [String,Pathname,Array<String,Pathname>] the path to
        # transform
        #
        # @return [String] the resulting path
        #
        # @example Portable Path
        #   require "staticky/files/path"
        #
        #   path = "path/to/file"
        #
        #   Staticky::Files::Path.call(path)
        #     # => "path/to/file" on UNIX based Operating System
        #
        #   Staticky::Files::Path.call(path)
        #     # => "path\to\file" on Windows Operating System
        #
        # @example Join Nested Tokens
        #   require "staticky/files/path"
        #
        #   path = ["path", ["to", ["nested", "file"]]]
        #
        #   Staticky::Files::Path.call(path)
        #     # => "path/to/nested/file" on UNIX based Operating System
        #
        #   Staticky::Files::Path.call(path)
        #     # => "path\to\nested\file" on Windows Operating System
        #
        # @example Separator path
        #   require "staticky/files/path"
        #
        #   path = ::File::SEPARATOR
        #
        #   Staticky::Files::Path.call(path)
        #     # => ""
        def call(*path)
          path = Array(path).flatten
          tokens = path.map do |token|
            split(token)
          end

          tokens
            .flatten
            .join(SEPARATOR)
        end
        alias [] call
      end

      # Split path according to the current Operating System directory separator
      #
      # @param path [String,Pathname] the path to split
      #
      # @return [Array<String>] the split path
      def self.split(path)
        return EMPTY_TOKEN if path == SEPARATOR

        path.to_s.split(%r{\\|/})
      end

      # Check if given path is absolute
      #
      # @param path [String,Pathname] the path to check
      #
      # @return [TrueClass,FalseClass] the result of the check
      def self.absolute?(path)
        path.start_with?(SEPARATOR)
      end

      # Returns all the path, except for the last token
      #
      # @param path [String,Pathname] the path to extract directory name from
      #
      # @return [String] the directory name
      def self.dirname(path)
        ::File.dirname(path)
      end
    end
  end
end
