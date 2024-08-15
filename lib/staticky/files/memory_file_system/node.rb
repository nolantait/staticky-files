# frozen_string_literal: true

require "stringio"

module Staticky
  class Files
    class MemoryFileSystem
      # Memory file system node (directory or file)
      #
      # File modes implementation inspired by https://www.calleluks.com/flags-bitmasks-and-unix-file-system-permissions-in-ruby/
      class Node
        MODE_USER_READ = 0b100000000
        MODE_USER_WRITE = 0b010000000
        MODE_USER_EXECUTE = 0b001000000
        MODE_GROUP_READ = 0b000100000
        MODE_GROUP_WRITE = 0b000010000
        MODE_GROUP_EXECUTE = 0b000001000
        MODE_OTHERS_READ = 0b000000100
        MODE_OTHERS_WRITE = 0b000000010
        MODE_OTHERS_EXECUTE = 0b000000001

        # Default directory mode: 0755
        DEFAULT_DIRECTORY_MODE = MODE_USER_READ | MODE_USER_WRITE | MODE_USER_EXECUTE |
          MODE_GROUP_READ | MODE_GROUP_EXECUTE |
          MODE_OTHERS_READ | MODE_GROUP_EXECUTE

        # Default file mode: 0644
        DEFAULT_FILE_MODE = MODE_USER_READ | MODE_USER_WRITE | MODE_GROUP_READ | MODE_OTHERS_READ

        MODE_BASE = 16
        ROOT_PATH = "/"

        # Instantiate a root node
        #
        # @return [Staticky::Files::MemoryFileSystem::Node] the root node
        def self.root
          new(ROOT_PATH)
        end

        attr_reader :segment, :mode, :children

        # Instantiate a new node.
        # It's a directory node by default.
        #
        # @param segment [String] the path segment of the node
        # @param mode [Integer] the UNIX mode
        #
        # @return [Staticky::Files::MemoryFileSystem::Node] the new node
        #
        # @see #mode=
        def initialize(segment, mode = DEFAULT_DIRECTORY_MODE)
          @segment = segment
          @children = nil
          @content = nil

          self.chmod = mode
        end

        # Get a node child
        #
        # @param segment [String] the child path segment
        #
        # @return [Staticky::Files::MemoryFileSystem::Node,NilClass] the child
        # node, if found
        def get(segment)
          @children&.fetch(segment, nil)
        end

        # Set a node child
        #
        # @param segment [String] the child path segment
        def set(segment)
          @children ||= {}
          @children[segment] ||= self.class.new(segment)
        end

        # Unset a node child
        #
        # @param segment [String] the child path segment
        #
        # @raise [Staticky::Files::UnknownMemoryNodeError] if the child node cannot be found
        def unset(segment)
          @children ||= {}
          raise UnknownMemoryNodeError, segment unless @children.key?(segment)

          @children.delete(segment)
        end

        # Check if node is a directory
        #
        # @return [TrueClass,FalseClass] the result of the check
        def directory?
          !file?
        end

        # Check if node is a file
        #
        # @return [TrueClass,FalseClass] the result of the check
        def file?
          !@content.nil?
        end

        # Read file contents
        #
        # @return [String] the file contents
        #
        # @raise [Staticky::Files::NotMemoryFileError] if node isn't a file
        def read
          raise NotMemoryFileError, segment unless file?

          @content.rewind
          @content.read
        end

        # Read file content lines
        #
        # @return [Array<String>] the file content lines
        #
        # @raise [Staticky::Files::NotMemoryFileError] if node isn't a file
        def readlines
          raise NotMemoryFileError, segment unless file?

          @content.rewind
          @content.readlines
        end

        # Write file contents
        # IMPORTANT: This operation turns a node into a file
        #
        # @param content [String, Array<String>] the file content
        #
        # @raise [Staticky::Files::NotMemoryFileError] if node isn't a file
        def write(content)
          content = case content
                    when String
                      content
                    when Array
                      array_to_string(content)
                    when NilClass
                      EMPTY_CONTENT
          end

          @content = StringIO.new(content)
          @mode = DEFAULT_FILE_MODE
        end

        # Set UNIX mode
        # It accepts base 2, 8, 10, and 16 numbers
        #
        # @param mode [Integer] the file mode
        def chmod=(mode)
          @mode = mode.to_s(MODE_BASE).hex
        end

        # Check if node is executable for user
        #
        # @return [TrueClass,FalseClass] the result of the check
        def executable?
          (mode & MODE_USER_EXECUTE).positive?
        end

        def array_to_string(content)
          content
            .map { |line| line.sub(NEW_LINE_MATCHER, EMPTY_CONTENT) }
            .join(NEW_LINE) + NEW_LINE
        end
      end
    end
  end
end
