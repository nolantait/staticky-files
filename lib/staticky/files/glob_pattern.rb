# frozen_string_literal: true

module Staticky
  class Files
    class GlobPattern
      attr_reader :pattern, :path

      # @param pattern [String] the glob pattern
      def initialize(pattern)
        @pattern = pattern
        @path = Pathname.new(pattern)
      end

      # @return [Array<GlobPattern>] the expanded glob pattern
      def expanded
        expand_braces(@pattern).map { GlobPattern.new(it) }
      end

      # Check if the pattern explicitly includes a dot that would match dotfiles
      # Patterns like ".*", "*/.*", "*/.*/*", etc.
      # But not if the dot is part of a normal file extension
      def dot?
        dotfile? ||
          pattern.include?(".*") ||
          pattern.include?("/.") ||
          pattern.include?("?.")
      end

      def directory?
        pattern.end_with?("/")
      end

      def relative?
        pattern.start_with?("./", "../")
      end

      def dotfile?
        pattern.start_with?(".") && !relative?
      end

      private

      # @return [Array<String>] the expanded patterns
      def expand_braces(pattern)
        if pattern.include?("{") && pattern.include?("}")
          start_idx = pattern.index("{")
          end_idx = pattern.index("}")
          prefix = pattern[0...start_idx]
          suffix = pattern[(end_idx + 1)..]
          options = pattern[(start_idx + 1)...end_idx].split(",")
          options.flat_map do |option|
            expand_braces("#{prefix}#{option}#{suffix}")
          end
        else
          [pattern]
        end
      end
    end
  end
end
