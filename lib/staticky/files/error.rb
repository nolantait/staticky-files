# frozen_string_literal: true

module Staticky
  class Files
    # Staticky::Files base error
    class Error < StandardError
    end

    # Wraps low level I/O errors
    #
    # @see https://ruby-doc.org/core/Errno.html
    class IOError < Error
      # Instantiate a new `Staticky::Files::IOError`
      #
      # @param cause [Exception] the low level exception
      #
      # @return [Staticky::Files::IOError] the new error
      def initialize(cause)
        super(cause.message)
        @_cause = cause
      end

      # The original exception
      #
      # @see https://ruby-doc.org/core/Exception.html#method-i-cause
      def cause
        @_cause
      end
    end

    # File manipulations error.
    # Raised when the given `target` cannot be found in `path`.
    class MissingTargetError < Error
      # @param target [String,Regexp] the missing target
      # @param path [String,Pathname] the file
      #
      # @return [Staticky::Files::MissingTargetError] the new error
      def initialize(target, path)
        super("cannot find `#{target}' in `#{path}'")

        @_target = target
        @_path = path
      end

      # The missing target
      #
      # @return [String, Regexp] the missing target
      def target
        @_target
      end

      # The missing target
      #
      # @return [String,Pathname] the file
      def path
        @_path
      end
    end

    # Unknown memory node
    #
    # Raised by the memory adapter (used for testing purposes)
    class UnknownMemoryNodeError < Error
      # Instantiate a new error
      #
      # @param node [String] node name
      def initialize(node)
        super("unknown memory node `#{node}'")
      end
    end

    # Not a memory file
    #
    # Raised by the memory adapter (used for testing purposes)
    class NotMemoryFileError < Error
      # Instantiate a new error
      #
      # @param path [String] path name
      def initialize(path)
        super("not a memory file `#{path}'")
      end
    end
  end
end
