# frozen_string_literal: true

require "staticky/files/path"

module Staticky
  class Files
    # Memory File System abstraction to support `Staticky::Files`
    class MemoryFileSystem # rubocop:disable Metrics/ClassLength
      EMPTY_CONTENT = ""

      require_relative "memory_file_system/node"

      # Creates a new instance
      #
      # @param root [Staticky::Files::MemoryFileSystem::Node] the root node of
      # the in-memory file system
      #
      # @return [Staticky::Files::MemoryFileSystem]
      def initialize(root: Node.root)
        @root = root
      end

      # Opens (or creates) a new file for read/write operations.
      #
      # @param path [String] the target file
      # @yieldparam [Staticky::Files::MemoryFileSystem::Node]
      # @return [Staticky::Files::MemoryFileSystem::Node]
      def open(path, *)
        file = touch(path)

        if block_given?
          yield file
        else
          file
        end
      end

      # Read file contents
      #
      # @param path [String, Array<String>] the target path
      # @return [String] the file contents
      #
      # @raise [Staticky::Files::IOError] in case the target path is a directory
      # or if the file cannot be found
      def read(path)
        path = Path[path]
        raise IOError, Errno::EISDIR.new(path.to_s) if directory?(path)

        file = find_file(path)
        raise IOError, Errno::ENOENT.new(path.to_s) if file.nil?

        file.read
      end

      # Reads the entire file specified by path as individual lines,
      # and returns those lines in an array
      #
      # @param path [String, Array<String>] the target path
      # @return [Array<String>] the file contents
      #
      # @raise [Staticky::Files::IOError] in case the target path is a directory
      # or if the file cannot be found, or if the file is not readable
      def readlines(path)
        path = Path[path]
        node = find(path)

        raise IOError, Errno::ENOENT.new(path.to_s) if node.nil?
        raise IOError, Errno::EISDIR.new(path.to_s) if node.directory?
        raise IOError, Errno::EACCES.new(path.to_s) unless node.readable?

        node.readlines
      end

      # Creates a file, if it doesn't exist, and set empty content.
      #
      # If the file was already existing, it's a no-op.
      #
      # @param path [String, Array<String>] the target path
      #
      # @raise [Staticky::Files::IOError] in case the target path is a directory
      def touch(path)
        path = Path[path]
        raise IOError, Errno::EISDIR.new(path.to_s) if directory?(path)

        content = read(path) if exist?(path)
        write(path, content || EMPTY_CONTENT)
      end

      # Creates a new file or rewrites the contents
      # of an existing file for the given path and content
      # All the intermediate directories are created.
      #
      # @param path [String, Array<String>] the target path
      # @param content [String, Array<String>] the content to write
      #
      # @raise [Staticky::Files::IOError] in case the target path is a directory
      def write(path, *content)
        path = Path[path]
        raise IOError, Errno::EISDIR.new(path.to_s) if directory?(path)

        node = @root

        for_each_segment(path) do |segment|
          node = node.set(segment)
          raise IOError, Errno::EACCES.new(path.to_s) unless node.readable?
        end

        node.write(*content)
        node
      end

      # Returns a new string formed by joining the strings using Operating
      # System path separator
      #
      # @param path [String,Array<String>] path tokens
      #
      # @return [String] the joined path
      def join(*path)
        Path[path]
      end

      # Converts a path to an absolute path.
      #
      # @param path [String,Array<String>] the path to the file
      # @param dir [String,Array<String>] the base directory
      def expand_path(path, dir)
        return path if Path.absolute?(path)

        join(dir, path)
      end

      # Returns the name of the current working directory.
      #
      # @return [String] the current working directory.
      def pwd
        @root.segment
      end

      # Temporary changes the current working directory of the process to the
      # given path and yield the given block.
      #
      # The argument `path` is intended to be a **directory**.
      #
      # @param path [String] the target directory
      # @param blk [Proc] the code to execute with the target directory
      #
      # @raise [Staticky::Files::IOError] if path cannot be found or it isn't a
      #   directory
      def chdir(path, &)
        path = Path[path]
        directory = find(path)

        raise IOError, Errno::ENOENT.new(path.to_s) if directory.nil?
        raise IOError, Errno::ENOTDIR.new(path.to_s) unless directory.directory?

        current_root = @root
        @root = directory
        yield
      ensure
        @root = current_root
      end

      # Creates a directory and all its parent directories.
      #
      # The argument `path` is intended to be a **directory** that you want to
      # explicitly create.
      #
      # @see #mkdir_p
      #
      # @param path [String,Array<String>] the directory to create
      #
      # @raise [Staticky::Files::IOError] in case path is an already existing
      # file, or the file system cannot be accessed
      def mkdir(path)
        path = Path[path]
        node = @root

        for_each_segment(path) do |segment|
          node = node.set(segment)
          raise IOError, Errno::EEXIST.new(path.to_s) if node.file?
          raise IOError, Errno::EACCES.new(path.to_s) unless node.readable?
        end
      end

      # Creates a directory and all its parent directories.
      #
      # The argument `path` is intended to be a **file**, where its
      # directory ancestors will be implicitly created.
      #
      # @see #mkdir
      #
      # @param path [String,Array<String>] the file that will be in the
      #   directories that this method creates
      #
      # @raise [Staticky::Files::IOError] in case of I/O error
      def mkdir_p(path)
        path = Path[path]

        mkdir(
          Path.dirname(path)
        )
      end

      # Copies file content from `source` to `destination`
      # All the intermediate `destination` directories are created.
      #
      # @param source [String,Array<String>] the file(s) or directory to copy
      # @param destination [String,Array<String>] the directory destination
      #
      # @raise [Staticky::Files::IOError] if source cannot be found
      def cp(source, destination)
        content = read(source)
        write(destination, content)
      end

      # Removes (deletes) a file
      #
      # @param path [String,Array<String>] the file to remove
      #
      # @raise [Staticky::Files::IOError] if path cannot be found or it's
      # a directory
      #
      # @see #rm_rf
      def rm(path)
        path = Path[path]
        file = nil
        parent = @root
        node = @root

        for_each_segment(path) do |segment|
          break unless node

          file = segment
          parent = node
          node = node.get(segment)
        end

        raise IOError, Errno::ENOENT.new(path.to_s) if node.nil?
        raise IOError, Errno::EPERM.new(path.to_s) if node.directory?

        parent.unset(file)
      end

      # Removes (deletes) a directory
      #
      # @param path [String,Array<String>] the directory to remove
      #
      # @raise [Staticky::Files::IOError] if path cannot be found
      #
      # @see #rm
      def rm_rf(path)
        path = Path[path]
        file = nil
        parent = @root
        node = @root

        for_each_segment(path) do |segment|
          break unless node

          file = segment
          parent = node
          node = node.get(segment)
        end

        raise IOError, Errno::ENOENT.new(path.to_s) if node.nil?

        parent.unset(file)
      end

      # Sets node UNIX mode
      #
      # @param path [String,Array<String>] the path to the node
      # @param mode [Integer] a UNIX mode, in base 2, 8, 10, or 16
      #
      # @raise [Staticky::Files::IOError] if path cannot be found
      def chmod(path, mode)
        path = Path[path]
        node = find(path)

        raise IOError, Errno::ENOENT.new(path.to_s) if node.nil?

        node.chmod = mode
      end

      # Gets node UNIX mode
      #
      # @param path [String,Array<String>] the path to the node
      # @return [Integer] the UNIX mode
      #
      # @raise [Staticky::Files::IOError] if path cannot be found
      def mode(path)
        path = Path[path]
        node = find(path)

        raise IOError, Errno::ENOENT.new(path.to_s) if node.nil?

        node.mode
      end

      # Check if the given path exist.
      #
      # @param path [String,Array<String>] the path to the node
      # @return [TrueClass,FalseClass] the result of the check
      def exist?(path)
        path = Path[path]

        !find(path).nil?
      end

      # Check if the given path corresponds to a directory.
      #
      # @param path [String,Array<String>] the path to the directory
      # @return [TrueClass,FalseClass] the result of the check
      def directory?(path)
        path = Path[path]
        !find_directory(path).nil?
      end

      # Check if the given path is an executable.
      #
      # @param path [String,Array<String>] the path to the node
      # @return [TrueClass,FalseClass] the result of the check
      def executable?(path)
        path = Path[path]

        node = find(path)
        return false if node.nil?

        node.executable?
      end

      # Reads entries from a directory
      #
      # @param path [String,Pathname] the path to file
      # @return [Array<String>] the entries
      #
      # @raise [Staticky::Files::IOError] in case of I/O error
      def entries(path)
        path = Path[path]
        node = find(path)
        raise IOError, Errno::ENOENT.new(path.to_s) if node.nil?
        raise IOError, Errno::ENOTDIR.new(path.to_s) unless node.directory?

        [".", ".."] + Array(node.children&.keys)
      end

      # Returns an array of file paths that match the given pattern.
      #
      # @param pattern [Pathname, String] the glob pattern to match
      # @return [Array<String>] the matching file paths
      def glob(pattern)
        pattern = pattern.to_s
        patterns = expand_braces(pattern)

        # Get the current working directory path relative to root
        current_dir = if @root == Node.root
          ""
        else
          build_path_from_root(@root)
        end

        # Collect all paths relative to current directory
        all_paths = collect_paths_relative_to_current_dir(current_dir)

        matches = []
        patterns.each do |expanded_pattern|
          # Determine if we should match dotfiles
          flags = File::FNM_PATHNAME
          flags |= File::FNM_DOTMATCH if pattern_has_dot?(expanded_pattern)

          # For each path, check if it matches the pattern
          all_paths.each do |path|
            # Handle directory-specific patterns
            if expanded_pattern.end_with?("/")
              # Check if the path is a directory and matches the pattern
              # without trailing slash
              if File.fnmatch(expanded_pattern[0..-2], path, flags)
                # Add trailing slash to indicate directory
                matches << "#{path}/"
              end
            elsif File.fnmatch(expanded_pattern, path, flags)
              matches << path
            end
          end
        end

        # Remove duplicates and sort
        matches.uniq.sort
      end

      private

      # Check if the pattern explicitly includes a dot that would match dotfiles
      # Patterns like ".*", "*/.*", "*/.*/*", etc.
      # But not if the dot is part of a normal file extension
      def pattern_has_dot?(pattern)
        pattern_is_relative = pattern.start_with?(".") &&
          !pattern.start_with?("./") &&
          !pattern.start_with?("../")

        pattern_is_relative ||
          pattern.include?(".*") ||
          pattern.include?("/.") ||
          pattern.include?("?.")
      end

      def build_path_from_root(node)
        # Since we don't have parent pointers, we need a different approach
        # Let's find the path by traversing from the root
        find_path_from_root(Node.root, node, "")
      end

      def find_path_from_root(current_node, target_node, current_path)
        # If we found the target node, return the path
        return current_path if current_node == target_node

        # If current node is a directory, check its children
        if current_node.directory? && current_node.children
          current_node.children.each do |segment, child|
            new_path = if current_path.empty?
              segment
            else
              File.join(
                current_path,
                segment
              )
            end
            result = find_path_from_root(child, target_node, new_path)
            return result if result
          end
        end

        nil
      end

      # @param current_dir [String] the current directory path
      def collect_paths_relative_to_current_dir(current_dir)
        # Start from the current directory (@root)
        paths = []

        # Helper function to collect paths
        collect_paths = ->(node, current_relative_path) do
          # Add the current path if it's not empty
          paths << current_relative_path unless current_relative_path.empty?

          # If it's a directory, recurse into children
          if node.directory? && node.children
            node.children.each do |segment, child|
              new_relative_path = if current_relative_path.empty?
                segment
              else
                File.join(current_relative_path, segment)
              end

              collect_paths.call(child, new_relative_path)
            end
          end
        end

        current_node = find_directory(current_dir) || @root
        # Start collecting from the current directory (@root)
        collect_paths.call(current_node, "")
        paths
      end

      def expand_braces(pattern)
        # Simple brace expansion for {a,b} patterns
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

      def for_each_segment(path, &)
        segments = Path.split(path)
        segments.each(&)
      end

      def find_directory(path)
        node = find(path)

        return if node.nil?
        return unless node.directory?

        node
      end

      def find_file(path)
        node = find(path)

        return if node.nil?
        return unless node.file?

        node
      end

      def find(path)
        node = @root

        for_each_segment(path) do |segment|
          break unless node

          node = node.get(segment)
        end

        node
      end
    end
  end
end
